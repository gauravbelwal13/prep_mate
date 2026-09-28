from uuid import uuid4

from app.core.jwt import (
    create_access_token,
    decode_access_token,
)


def test_jwt() -> None:
    user_id = uuid4()

    token = create_access_token(
        user_id=user_id,
    )

    decoded_user_id = decode_access_token(
        token=token,
    )

    print(f"Original user ID: {user_id}")
    print(f"JWT: {token}")
    print(f"Decoded user ID: {decoded_user_id}")
    print(f"Match: {user_id == decoded_user_id}")