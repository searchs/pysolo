"""Money and Currency types for financial operations.

This module provides a small, precise `Money` value object and a
`Currency` alias for currency codes.
"""

from __future__ import annotations

from dataclasses import dataclass
from decimal import ROUND_HALF_UP, Decimal
from typing import NewType

Currency = NewType("Currency", str)
"""
Type alias for currency codes (e.g., ``'USD'``, ``'GBP'``).

This is a thin wrapper over ``str`` used to make function/type
signatures more expressive.
"""


@dataclass(frozen=True, slots=True)
class Money:
    """Value object representing an amount of money in a currency.

    Args:
        amount: The monetary amount as a :class:`decimal.Decimal` for
            exactness and to avoid floating point rounding errors.
        currency: The currency code as a :class:`Currency` (alias of
            :class:`str`).

    Attributes:
        amount: See above.
        currency: See above.
    """

    amount: Decimal
    currency: Currency

    def quantize(self, exp: str = "0.01", rounding=ROUND_HALF_UP) -> Money:
        """Return a new :class:`Money` with the amount quantized.

        Args:
            exp: Decimal exponent string for quantization. Defaults to
                ``"0.01"`` which rounds to 2 decimal places.
            rounding: Rounding mode from :mod:`decimal` (defaults to
                :data:`decimal.ROUND_HALF_UP`).

        Returns:
            Money: A new :class:`Money` instance with the quantized amount
            and the same currency.
        """

        q = Decimal(exp)
        return Money(
            amount=self.amount.quantize(q, rounding=rounding), currency=self.currency
        )
