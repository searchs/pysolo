from decimal import ROUND_DOWN, ROUND_UP, Decimal

from finops import Currency, Money
from finops.money import ROUND_HALF_UP


def test_money_creation():
    """Test creating a Money instance."""
    m = Money(amount=Decimal("10.50"), currency=Currency("USD"))
    assert m.amount == Decimal("10.50")
    assert m.currency == "USD"


def test_money_quantize_default():
    """Test quantizing with default parameters (2 decimal places, ROUND_HALF_UP)."""
    m = Money(amount=Decimal("10.005"), currency=Currency("GBP"))
    result = m.quantize()
    assert str(result.amount) == "10.01"
    assert result.currency == "GBP"


def test_money_quantize_four_decimals():
    """Test quantizing with 4 decimal places."""
    m = Money(amount=Decimal("10.12345"), currency=Currency("EUR"))
    result = m.quantize(exp="0.0001")
    assert str(result.amount) == "10.1235"
    assert result.currency == "EUR"


def test_money_quantize_round_down():
    """Test quantizing with ROUND_DOWN mode."""
    m = Money(amount=Decimal("10.005"), currency=Currency("JPY"))
    result = m.quantize(rounding=ROUND_DOWN)
    assert str(result.amount) == "10.00"
    assert result.currency == "JPY"


def test_money_quantize_round_up():
    """Test quantizing with ROUND_UP mode."""
    m = Money(amount=Decimal("10.001"), currency=Currency("CHF"))
    result = m.quantize(rounding=ROUND_UP)
    assert str(result.amount) == "10.01"
    assert result.currency == "CHF"


def test_money_immutable():
    """Test that Money instances are immutable (frozen)."""
    m = Money(amount=Decimal("100"), currency=Currency("USD"))
    try:
        m.amount = Decimal("200")
        assert False, "Should not be able to modify frozen dataclass"
    except (AttributeError, TypeError):
        pass  # Expected - frozen dataclasses cannot be modified


def test_currency_type():
    """Test that Currency is correctly typed."""
    curr = Currency("CAD")
    assert curr == "CAD"
    assert isinstance(curr, str)
