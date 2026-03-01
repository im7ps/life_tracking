import httpx
import asyncio

async def test_portfolio():
    url = "http://localhost:8000/api/v1"
    
    # 1. Login (assuming user 'test' exists, or adjust as needed)
    # If no user exists, we might need to register one first
    try:
        login_data = {"username": "test", "password": "password"}
        async with httpx.AsyncClient() as client:
            print("Tentativo di login...")
            response = await client.post(f"{url}/auth/login", data=login_data)
            if response.status_code != 200:
                print(f"Login fallito: {response.text}")
                # Try signup
                print("Tentativo di registrazione...")
                await client.post(f"{url}/auth/signup", json={
                    "username": "test", 
                    "email": "test@example.com", 
                    "password": "password"
                })
                response = await client.post(f"{url}/auth/login", data=login_data)
            
            token = response.json()["access_token"]
            headers = {"Authorization": f"Bearer {token}"}
            
            # 2. Call Portfolio
            print("Chiamata a /portfolio...")
            response = await client.get(f"{url}/actions/portfolio", headers=headers)
            print(f"Status Portfolio: {response.status_code}")
            if response.status_code == 200:
                print("Successo!")
                # print(response.json())
            else:
                print(f"Errore: {response.text}")

    except Exception as e:
        print(f"Eccezione: {e}")

if __name__ == "__main__":
    asyncio.run(test_portfolio())
