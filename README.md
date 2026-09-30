# pysolo

Open-source financial operations primitives for Python.

## Quickstart

```bash
uv sync
uv run pytest
```

## Example

The distribution is currently published as `pysolo`, while the Python import package is `finops`.

```python
from decimal import Decimal

from finops import Currency, Money

money = Money(Decimal("10.005"), Currency("GBP"))
print(money.quantize())  # 10.01 GBP (rounded)
```

The import namespace is intentionally documented as it exists today. Aligning the import package itself with the `pysolo` distribution name should be handled as an explicit compatibility/breaking-release decision rather than a silent rename.
