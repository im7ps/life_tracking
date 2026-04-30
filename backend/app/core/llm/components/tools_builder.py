from langgraph.prebuilt import ToolNode

def build_tool_node(tool_list) -> ToolNode:
    return ToolNode(tool_list, handle_tool_errors=True)
