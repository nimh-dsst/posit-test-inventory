from pathlib import Path

import pandas as pd
import streamlit as st


st.set_page_config(page_title="Specimen inventory", layout="wide")
st.title("Specimen inventory")

data_path = Path(__file__).parent / "data" / "example.csv"
specimens = pd.read_csv(data_path, parse_dates=["DateCollected"])
specimen_types = ["CSF", "Blood", "Tissue"]

st.caption("All specimens in the inventory")
columns = st.columns(4)
columns[0].metric("Total specimens", f"{len(specimens):,}")
for column, specimen_type in zip(columns[1:], specimen_types):
    count = specimens["Type"].eq(specimen_type).sum()
    column.metric(specimen_type, f"{count:,}")

st.subheader("Samples collected")
if specimens.empty:
    st.info("There are no specimens to plot.")
    st.stop()

frequencies = {"Month": "M", "Quarter": "Q", "Year": "Y"}
first_date = specimens["DateCollected"].min().date()
last_date = specimens["DateCollected"].max().date()

with st.sidebar:
    st.header("Chart filters")
    binning = st.selectbox("Group by", list(frequencies), index=0)
    selected_types = st.multiselect(
        "Specimen types", specimen_types, default=specimen_types
    )
    date_range = st.date_input(
        "Collection date range",
        value=(first_date, last_date),
        min_value=first_date,
        max_value=last_date,
        format="YYYY-MM-DD",
    )

if len(date_range) != 2:
    st.info("Select both a start date and an end date to display the chart.")
    st.stop()

start_date, end_date = date_range
filtered = specimens.loc[
    specimens["Type"].isin(selected_types)
    & specimens["DateCollected"].dt.date.between(start_date, end_date)
]

st.caption(f"Showing {len(filtered):,} of {len(specimens):,} specimens")
if filtered.empty:
    st.info("No specimens match the selected filters.")
    st.stop()

frequency = frequencies[binning]
periods = pd.period_range(start_date, end_date, freq=frequency)
counts = (
    filtered.groupby(filtered["DateCollected"].dt.to_period(frequency))
    .size()
    .reindex(periods, fill_value=0)
    .rename_axis("Collection period")
    .rename("Specimens")
)
counts.index = counts.index.astype(str)

st.bar_chart(
    counts.reset_index(),
    x="Collection period",
    y="Specimens",
    height=400,
)
