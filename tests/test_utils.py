from datetime import date

from utils.common import is_business_day, previous_business_day


def test_is_business_day_weekday():
    d = date(2025, 12, 31)  # Wednesday
    assert is_business_day(d) is True


def test_is_business_day_weekend():
    d = date(2026, 1, 3)  # Saturday
    assert is_business_day(d) is False


def test_is_business_day_holiday():
    d = date(2025, 12, 25)  # Christmas
    holidays = [d.isoformat()]
    assert is_business_day(d, holidays) is False


def test_previous_business_day_from_weekend():
    # Sunday -> previous business day is Friday
    as_of = date(2026, 1, 4)  # Sunday
    prev = previous_business_day(as_of)
    assert prev.weekday() < 5


def test_previous_business_day_with_holiday():
    # If Friday is a holiday, previous business day before Saturday should be Thursday
    as_of = date(2026, 1, 3)  # Saturday
    holiday = date(2026, 1, 2).isoformat()  # Friday
    prev = previous_business_day(as_of, holidays=[holiday])
    assert prev == date(2026, 1, 1)  # Thursday
