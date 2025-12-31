# pysolo

Open-source financial operations primitives for Python.

## Quickstart

```bash
uv sync
uv run pytest
```

## Example

```python
from decimal import Decimal
from pysolo.money import Money, Currency

m = Money(Decimal("10.005"), Currency("GBP"))
print(m.quantize())  # 10.01 GBP (rounded)
```
