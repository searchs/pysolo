from __future__ import annotations

from dataclasses import dataclass
from decimal import ROUND_HALF_UP, Decimal
from typing import NewType

Currency = NewType("Currency", str)


@dataclass(frozen=True, slots=True)
class Money:
    amount: Decimal
    currency: Currency

    def quantize(self, exp: str = "0.01", rounding=ROUND_HALF_UP) -> Money:
        q = Decimal(exp)
        return Money(amount=self.amount.quantize(q, rounding=rounding), currency=self.currency)
