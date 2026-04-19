from langchain_core.messages import BaseMessage
from langgraph.graph.message import add_messages
from typing import Annotated, TypedDict


class Graph(TypedDict, total=False):
    messages: Annotated[list[BaseMessage], add_messages]
    category: str
