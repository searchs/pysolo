"""Money and Currency types for financial operations."""

from __future__ import annotations

from dataclasses import dataclass
from decimal import ROUND_HALF_UP, Decimal
from typing import NewType

Currency = NewType("Currency", str)
"""Type alias for currency codes (e.g., 'USD', 'GBP')."""


@dataclass(frozen=True, slots=True)
class Money:
    """Represents an amount of money in a specific currency.

    Attributes:
        amount: The monetary amount as a Decimal for precision.
        currency: The currency code as a Currency type.
    """

    amount: Decimal
    currency: Currency

    def quantize(self, exp: str = "0.01", rounding=ROUND_HALF_UP) -> Money:
        """Quantize the monetary amount to a specific decimal precision.

        Args:
            exp: The exponent for quantization (default: "0.01" for 2 decimal places).
            rounding: The rounding mode (default: ROUND_HALF_UP).

        Returns:
            A new Money instance with the quantized amount.
        """
        q = Decimal(exp)
        return Money(
            amount=self.amount.quantize(q, rounding=rounding), currency=self.currency
        )
