from decimal import Decimal

from finops.money import Currency, Money


def test_money_quantize():
    m = Money(amount=Decimal("10.005"), currency=Currency("GBP"))
    assert str(m.quantize().amount) == "10.01"
