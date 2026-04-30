
from app.core.llm.components.graph import Graph
from app.core.llm.components.nodes import handle_portfolio, handle_rank, modify_category

from langchain_core.messages import HumanMessage
from langgraph.graph import StateGraph, START, END

from typing import Literal, Hashable
import asyncio

from dotenv import load_dotenv
load_dotenv()

async def simple_router(state: Graph) -> Literal["portfolio", "rank", "__end__"]:
    last_input = ""
    messages = state.get("messages", [])
    if messages:
        last_input = messages[-1].content
        if "portfolio" in last_input:
            return "portfolio"
        elif "rank" in last_input:
            return "rank"
    return "__end__"

def build_workflow(simple_router):
    my_map: dict[Hashable, str] = {
        "portfolio": "portfolio_node",
        "rank": "rank_node",
        "modifica": "modify_category_node",
        "__end__": END
    }
    workflow = StateGraph(Graph)
    workflow.add_node("portfolio_node", handle_portfolio)
    workflow.add_node("rank_node", handle_rank)
    workflow.add_node("modify_category_node", modify_category)
    workflow.add_edge("rank_node", "modify_category_node")
    workflow.add_edge("portfolio_node", END)
    workflow.add_conditional_edges(START, simple_router, my_map)
    workflow.add_conditional_edges("modify_category_node", simple_router, my_map)
    return workflow



async def test():
    workflow = build_workflow(simple_router=simple_router)
    app = workflow.compile()
    inputs: Graph = {
        "messages": [HumanMessage(content="Voglio vedere il mio rank")],
        "category": "initial_category",
        }
    result = await app.ainvoke(inputs, config={"recursion_limit": 10})
    print(result)

if __name__ == "__main__":
    asyncio.run(test())