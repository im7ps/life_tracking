from app.core.llm.components.graph import Graph

async def invoke_model(state: Graph):
    from app.core.llm.components.llm import fetch_llm
    model = fetch_llm()
    messages = state.get("messages", [])
    response = ""
    if messages:
        response = await model.ainvoke(messages)
    return {"messages": [response]}

async def invoke_model_with_tools(state: Graph, tool_list: list):
    from app.core.llm.components.llm import fetch_llm_with_tools
    model = fetch_llm_with_tools(tool_list)
    messages = state.get("messages", [])
    response = ""
    if messages:
        response = await model.ainvoke(messages)
    return {"messages": [response]}