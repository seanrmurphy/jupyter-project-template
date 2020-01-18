from mypymodule.utils import (
    greeting
)


def test_greeting():
    assert greeting('user') == 'Hello user'
