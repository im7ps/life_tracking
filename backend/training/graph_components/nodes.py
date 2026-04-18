from .graph import Graph

def modify_category(state: Graph):
    # print("-----\nI'm modifing the category")
    return {
        "cronologia": "",
        "category": "sunset"
        }

def handle_portfolio(state: Graph):
    return {"category": "portfolio_m"}

def handle_rank(state: Graph):
    return {"category": "rank_m"}