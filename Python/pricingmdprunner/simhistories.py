import numpy as np
import pandas as pd
import plotly.graph_objects as go


def vec_from_str(s):
    vec = []
    for c in s:
        vec.append(int(c))
    return np.array(vec)


def prepare_simhistory(df, tdf, tid, runner, e_res):
    # tid = 1
    # e_res = 72
    # runner = "Oracle"
    simhistory = df[(df.runner == runner) & (df.expected_res == e_res) & (df.trace_id == tid)]
    trace = tdf[(tdf.expected_res == e_res) & (tdf.trace_id == tid)]

    # Some simhistory may terminate before the end of the trace since no sale is possible after c=0
    assert all(trace.timestep == simhistory.timestep)
    assert all(trace["product"] == simhistory["product"])

    sh = simhistory.copy().reset_index()
    sh.loc[:, "allocation_row"] = np.nan
    sh.loc[:, "n_product_res"] = sh.prod_vec.apply(sum)
    sh.loc[:, "revenue"] = sh.sold * sh.action * sh.n_product_res

    sh.loc[:, "prod_tslot_start"] = sh.prod_vec.apply(lambda x: np.nonzero(x)[0][0])
    sh.loc[:, "prod_tslot_end"] = sh.prod_vec.apply(lambda x: np.nonzero(x)[0][-1])

    return sh


def allocation_from_simhistory(sh):
    # sh.loc[:, "allocation_row"] = np.nan
    dim = (len(sh), len(sh.prod_vec.iloc[0]))
    cs_allocation = np.zeros(dim, dtype=float)
    cs_allocation_info = np.zeros(dim, dtype=dict)

    # assert len(sh.c.unique()) == 1
    # c = sh.c.unique()[0]

    for i, record in sh.iterrows():
        # print(trace[1].prod_vec)
        product = record.prod_vec
        budget = record.budget
        action = record.action
        timestep = record.timestep
        allocation_row = 0
        while True:
            if np.max(cs_allocation[allocation_row, :] + product) <= 1:
                cs_allocation[allocation_row, :] += product
                cs_allocation_info[allocation_row, (product == 1)] = {"timestep": timestep, "budget": budget,
                                                                      "action": action}
                sh.loc[i, "allocation_row"] = allocation_row
                break
            else:
                allocation_row += 1

    # if last row is empty, remove all empty rows
    if np.sum(cs_allocation[-1, :]) == 0:
        first_empty_row = np.where(~cs_allocation.any(axis=1))[0][0]
        cs_allocation = cs_allocation[:first_empty_row, :]
        cs_allocation_info = cs_allocation_info[:first_empty_row, :]

    return np.flip(cs_allocation, axis=0), np.flip(cs_allocation_info, axis=0), sh


def sold_unsold_allocation_from_simhistory(sh):
    _, _, sh_sold = allocation_from_simhistory(sh[sh.sold])
    _, _, sh_unsold = allocation_from_simhistory(sh[~sh.sold])

    sh = pd.concat([sh_sold, sh_unsold])
    return sh


def add_product_boxes(fig, alloc, y_offset=0, fillcolor='rgba(26,150,65,0.5)'):
    # Add shapes
    for i, record in alloc.iterrows():
        box_height = 1

        x0 = record.prod_tslot_start
        y0 = record.allocation_row + y_offset
        x1 = record.prod_tslot_end + 1
        y1 = record.allocation_row + box_height + y_offset
        fig.add_shape(type="rect",
                      x0=x0, x1=x1, y0=y0, y1=y1,
                      line=dict(color="White", width=1),
                      # color with alpha
                      fillcolor=fillcolor
                      )
        # Adding a trace with a fill, setting opacity to 0
        fig.add_trace(
            go.Scatter(
                x=[x0, x1, x1, x0, x0],
                y=[y0, y0, y1, y1, y0],
                fill="toself",
                mode='lines',
                name='',
                text=f"timestep: {record.timestep}, budget: {record.budget}, action: {record.action}",
                opacity=0
            )
        )
    return fig


def plot_simhistory_sold_unsold(alloc, x_range=24):
    fig = go.Figure()

    # Set axes properties
    fig.update_xaxes(range=[0, x_range],
                     showgrid=False
                     )
    y_range = int(alloc.allocation_row.max()) + 1
    fig.update_yaxes(range=[0, y_range])

    # Add shapes
    y_offset = 0
    fig = add_product_boxes(fig, alloc[alloc.sold], y_offset=y_offset, fillcolor='rgba(0, 204, 150,0.5)')
    unsold_y_offset = alloc[alloc.sold].allocation_row.max() + 1
    fig = add_product_boxes(fig, alloc[~alloc.sold], y_offset=unsold_y_offset, fillcolor='rgba(239, 85, 59,0.5)')

    fig.update_shapes(dict(xref='x', yref='y'))

    fig.update_layout(
        width=800,  # 576,  # 6 inches * 96 pixels/inch
        height=400,  # 384,  # 4 inches * 96 pixels/inch (or adjust based on your needs)
        plot_bgcolor='rgba(0, 0, 0, 0)',  # Transparent background inside the plot
        paper_bgcolor='rgba(0, 0, 0, 0)',  # Transparent background outside the plot
        margin=dict(l=0, r=0, t=0, b=0),  # Adjust margins to make space for border
        xaxis=None,
        yaxis=dict(showticklabels=False),
        # Optional: Add border around the entire plot area
        # shapes=[dict(
        #     type='rect',
        #     x0=0, y0=0, x1=1, y1=1,
        #     xref='paper', yref='paper',
        #     line=dict(color='black', width=1)
        # )]
    )

    return fig

TEST=5

def add_revenue_boxes(fig, alloc):
    sold_alloc = alloc[alloc.sold]
    sold_revenue_range = ((sold_alloc.budget / sold_alloc.n_product_res).min(),
                          (sold_alloc.budget / sold_alloc.n_product_res).max())
    y_offset = 0
    for i, record in sold_alloc.iterrows():
        # box_height=1
        # box_height = (record.revenue/record.n_product_res - sold_revenue_range[0]) / (sold_revenue_range[1] - sold_revenue_range[0])
        box_height = (record.revenue / record.n_product_res) / sold_revenue_range[1]
        x0 = record.prod_tslot_start
        y0 = record.allocation_row + y_offset
        x1 = record.prod_tslot_end + 1
        y1 = record.allocation_row + box_height + y_offset
        fig.add_shape(type="rect",
                      x0=x0, x1=x1, y0=y0, y1=y1,
                      line=dict(color="White", width=1),
                      # color with alpha
                      fillcolor='rgba(0, 204, 150,1)'
                      )
    fig.update_shapes(dict(xref='x', yref='y'))
    return fig