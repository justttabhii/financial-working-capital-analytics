from pathlib import Path
import pandas as pd

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "data"

def load(name, **kwargs):
    return pd.read_csv(DATA / name, **kwargs)

customers = load("customers.csv")
products = load("products.csv")
orders = load("orders.csv", parse_dates=["order_date"])
items = load("order_items.csv")
invoices = load("invoices.csv", parse_dates=["invoice_date", "due_date"])
payments = load("payments.csv", parse_dates=["payment_date"])
inventory = load("inventory_snapshots.csv", parse_dates=["snapshot_date"])

results = []
def test(name, passed, details):
    results.append((name, bool(passed), details))

test("Unique customer IDs", customers.customer_id.is_unique, f"{customers.customer_id.nunique()} unique IDs / {len(customers)} rows")
test("Unique product IDs", products.product_id.is_unique, f"{products.product_id.nunique()} unique IDs / {len(products)} rows")
test("Unique order IDs", orders.order_id.is_unique, f"{orders.order_id.nunique()} unique IDs / {len(orders)} rows")
test("Unique invoice IDs", invoices.invoice_id.is_unique, f"{invoices.invoice_id.nunique()} unique IDs / {len(invoices)} rows")
test("Orders have known customers", orders.customer_id.isin(customers.customer_id).all(), "No orphan customer references")
test("Items have known orders", items.order_id.isin(orders.order_id).all(), "No orphan order references")
test("Items have known products", items.product_id.isin(products.product_id).all(), "No orphan product references")
test("Payments have known invoices", payments.invoice_id.isin(invoices.invoice_id).all(), "No orphan invoice references")
test("Non-negative inventory", (inventory.stock_quantity >= 0).all(), "All quantities are >= 0")

item_sales = items.merge(products[["product_id","unit_cost"]], on="product_id", validate="many_to_one")
item_sales["net_sales"] = item_sales.quantity * item_sales.unit_selling_price - item_sales.discount_amount
item_sales["cogs"] = item_sales.quantity * item_sales.unit_cost
per_order = item_sales.groupby("order_id", as_index=False).net_sales.sum()
recon = invoices.merge(per_order, on="order_id", validate="one_to_one")
recon["difference"] = (recon.invoice_amount - recon.net_sales).round(2)
test("Invoice-to-order reconciliation", recon.difference.abs().max() <= 0.01, f"Maximum absolute difference = {recon.difference.abs().max():.2f}")

paid = payments.groupby("invoice_id").payment_amount.sum()
paid_full = invoices.set_index("invoice_id").invoice_amount.sub(paid, fill_value=0)
test("Payments do not exceed invoice amount", (paid_full >= -0.01).all(), "Aggregated payments <= invoice amount within 1 cent")

revenue = item_sales.net_sales.sum()
cogs = item_sales.cogs.sum()
print("DATA COUNTS")
for name, df in [("customers",customers),("products",products),("orders",orders),("order_items",items),
                 ("invoices",invoices),("payments",payments),("inventory_snapshots",inventory)]:
    print(f"  {name}: {len(df):,}")
print(f"\nCross-check metrics (synthetic data):")
print(f"  Net sales: ₹{revenue:,.2f}")
print(f"  COGS: ₹{cogs:,.2f}")
print(f"  Gross profit: ₹{revenue-cogs:,.2f}")
print(f"  Gross margin: {(revenue-cogs)/revenue*100:.2f}%")
print("\nVALIDATION")
for name, passed, details in results:
    print(f"  [{'PASS' if passed else 'FAIL'}] {name}: {details}")
if not all(p for _, p, _ in results):
    raise SystemExit("Validation failed. Investigate the failed checks before continuing.")
