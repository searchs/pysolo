"""Common helper utilities.

Utilities for working with dates used across the project.
"""

from __future__ import annotations

from datetime import date as dd
from datetime import timedelta as td


def is_business_day(d: dd, holidays: list[str] | None = None) -> bool:
    """Return True if ``d`` is a business day (not a weekend or holiday).

    Args:
        d: The date to check.
        holidays: Optional list of holiday dates in ``YYYY-MM-DD`` string
            format. If provided, a date matching one of these strings is
            considered a non-business day.

    Returns:
        True if ``d`` is a weekday and not in ``holidays``; otherwise False.
    """

    return d.weekday() < 5 and (not holidays or d.strftime("%Y-%m-%d") not in set(holidays))


def previous_business_day(as_of: dd, holidays: list[str] | None = None) -> dd:
    """Return the most recent business day on or before ``as_of``.

    Args:
        as_of: The date to start searching from.
        holidays: Optional list of holiday dates in ``YYYY-MM-DD`` format.

    Returns:
        A :class:`datetime.date` representing the previous business day.
    """

    d = as_of
    while not is_business_day(d, holidays):
        d = d - td(days=1)
    return d
