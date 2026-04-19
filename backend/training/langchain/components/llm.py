from langchain_google_genai import ChatGoogleGenerativeAI
from app.core.config import settings
from typing import Any

def fetch_llm() -> ChatGoogleGenerativeAI:
    llm = ChatGoogleGenerativeAI(
        model="gemini-2.5-flash",
        google_api_key=settings.GOOGLE_API_KEY,
        temperature=0.1,
    )
    return llm

def fetch_llm_with_tools(tool_list) -> Any:
    llm = fetch_llm()
    return llm.bind_tools(tool_list)