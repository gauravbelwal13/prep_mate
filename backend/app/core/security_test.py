from app.core.security import hash_password, verify_password


def test_password_hashing() -> None:
    password = "TestPassword123!"

    hashed_password = hash_password(password)

    print(f"Hash: {hashed_password}")
    print(
        f"Correct password: "
        f"{verify_password(password, hashed_password)}"
    )
    print(
        f"Wrong password: "
        f"{verify_password('WrongPassword', hashed_password)}"
    )