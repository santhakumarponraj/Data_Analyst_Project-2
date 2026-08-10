# %% [markdown]
# 
# 
# <div style="background: linear-gradient(90deg, #00B8D9, #00ACC1); padding: 40px 20px; border-radius: 15px; text-align: center; animation: fadeIn 2s ease-in-out;">
# <h1 style="text-align:center; color:white; font-size:48px; margin-bottom: 10px">Supply Chain Analysis</h1>
# <h3 style="text-align:center; color:#ECEFF1; font-weight:normal; font-size: 20px;">Exploring logistics, revenue, and performance metrics</h3>
# </div>
# 
# <style>
# @keyframes fadeIn {
#   from { opacity: 0; transform: translateY(-10px); }
#   to { opacity: 1; transform: translateY(0); }
# }
# </style>
# 

# %% [markdown]
# # Requirements

# %%
# Import  libraries
import pandas as pd
import numpy as np
import plotly.express as px
import plotly.graph_objects as go
from plotly.subplots import make_subplots

# %% [markdown]
# # Load the cleaned dataset

# %%
# Load Data
df = pd.read_csv("data/SCA.csv")

# Display the dataset preview
print("Dataset Preview:")
display(df.head())  

# %%
num_rows, num_cols = df.shape

print(f'Number of rows: {num_rows}')
print(f'Number of columns: {num_cols}')

# %% [markdown]
# # Product Performance Analysis

# %%
# --- Product Performance Analysis ---
print("\n=== Product Performance Analysis ===")
product_summary = df.groupby(['Product_type', 'SKU']).agg({
    'Revenue_generated': 'sum',
    'Number_of_products_sold': 'sum',
    'Price': 'mean'
}).reset_index()
display(product_summary.head())  # Display the first few rows of the summary for verification

# Define consistent colors for Product_type
color_map = {
    'haircare': '#ADD8E6',   # Light Blue
    'skincare': '#90EE90',   # Light Green
    'cosmetics': '#FF7F50'   # Dark Orange
}

# Pie Chart: Sales by Product Type (Number of Products Sold)
sales_by_product_type = df.groupby('Product_type')['Number_of_products_sold'].sum().reset_index()
fig_sales_pie = px.pie(sales_by_product_type, 
                       values='Number_of_products_sold', 
                       names='Product_type', 
                       title='Sales Distribution by Product Type',
                       color='Product_type',  # Use Product_type for color mapping
                       color_discrete_map=color_map,  # Apply custom colors
                       hole=0.3)  # Donut style for visual appeal
fig_sales_pie.update_traces(textinfo='percent+label', 
                            pull=[0.1] * len(sales_by_product_type),  # Pull all slices slightly
                            marker=dict(line=dict(color='#000000', width=2)))  # Black borders
fig_sales_pie.update_layout(showlegend=True, 
                            legend_title_text='Product Type')
fig_sales_pie.show()

# Interactive Scatter Plot: Revenue vs Products Sold
fig_rev_prod = px.scatter(product_summary, x='Number_of_products_sold', y='Revenue_generated', 
                  color='Product_type', size='Price', hover_data=['SKU'],
                  title='Revenue vs Number of Products Sold by Product Type',
                  labels={'Number_of_products_sold': 'Number of Products Sold', 'Revenue_generated': 'Revenue Generated'},
                  color_discrete_map=color_map)  # Apply custom colors
fig_rev_prod.update_traces(marker=dict(line=dict(color='#000000', width=1)))  # Add borders
fig_rev_prod.update_layout(showlegend=True, 
                   legend_title_text='Product Type',
                   hovermode='closest')
fig_rev_prod.show()

# Visualization: Revenue Generated vs Price by Product Type
fig_revenue_price = px.scatter(df, x='Price', y='Revenue_generated', 
                               color='Product_type', size='Number_of_products_sold', hover_data=['SKU'],
                               title='Revenue Generated vs Price by Product Type',
                               labels={'Price': 'Price ($)', 'Revenue_generated': 'Revenue Generated ($)'},
                               color_discrete_map=color_map)  # Apply custom colors
fig_revenue_price.update_traces(marker=dict(line=dict(color='#000000', width=1)))
fig_revenue_price.update_layout(showlegend=True, 
                                legend_title_text='Product Type',
                                hovermode='closest')
fig_revenue_price.show()

# %% [markdown]
# # Customer Demographics Analysis

# %%
# --- Customer Demographics Analysis ---
print("\n=== Customer Demographics Analysis ===")

# Define consistent colors for Product_type (from previous sections)
color_map = {
    'haircare': '#ADD8E6',  # Light Blue
    'skincare': '#90EE90',  # Light Green
    'cosmetics': '#FFA500'  # Orange (if present)
}

#  Revenue Distribution by Customer Demographics (Pie Chart)
revenue_by_demo = df.groupby('Customer_demographics')['Revenue_generated'].sum().reset_index()
fig_revenue_pie = px.pie(revenue_by_demo, 
                         values='Revenue_generated', 
                         names='Customer_demographics', 
                         title='Revenue Distribution by Customer Demographics',
                         color_discrete_sequence=px.colors.qualitative.Plotly,
                         hole=0.3)
fig_revenue_pie.update_traces(textinfo='percent+label', 
                              pull=[0.1] * len(revenue_by_demo), 
                              marker=dict(line=dict(color='#000000', width=2)))
fig_revenue_pie.update_layout(showlegend=True,
                              legend_title_text='Customer Demographics')
fig_revenue_pie.show()

#  Product Sales by Product Type and Customer Demographics (Bar Chart)
sales_by_demo_product = df.groupby(['Product_type', 'Customer_demographics'])['Number_of_products_sold'].sum().reset_index()
fig_sales_demo = px.bar(sales_by_demo_product, 
                        x='Customer_demographics', 
                        y='Number_of_products_sold', 
                        color='Product_type', 
                        barmode='group',  # Group bars side by side
                        title='Product Sales by Product Type and Customer Demographics',
                        labels={'Number_of_products_sold': 'Total Units Sold', 'Customer_demographics': 'Customer Demographics'},
                        color_discrete_map=color_map)
fig_sales_demo.update_traces(marker=dict(line=dict(color='#000000', width=1)), width=0.3)
fig_sales_demo.update_layout(showlegend=True,
                             legend_title_text='Product Type',
                             xaxis_title='Customer Demographics',
                             yaxis_title='Total Units Sold',
                             bargap=0.2,
                             title_font=dict(size=16))
fig_sales_demo.show()

#  Supplier Distribution by Customer Demographics (Bar Chart)
supplier_by_demo = df.groupby(['Supplier_name', 'Customer_demographics']).size().reset_index(name='Count')
fig_supplier_demo = px.bar(supplier_by_demo, 
                           x='Supplier_name', 
                           y='Count', 
                           color='Customer_demographics', 
                           barmode='stack',  # Stack bars for total supplier count
                           title='Supplier Distribution by Customer Demographics',
                           labels={'Count': 'Number of Products', 'Supplier_name': 'Supplier'})
fig_supplier_demo.update_traces(marker=dict(line=dict(color='#000000', width=1)))
fig_supplier_demo.update_layout(showlegend=True,
                                legend_title_text='Customer Demographics',
                                xaxis_title='Supplier',
                                yaxis_title='Number of Products',
                                bargap=0.2,
                                title_font=dict(size=16))
fig_supplier_demo.show()



# %%
# --- Customer Demographics Analysis ---
print("\n=== Customer Demographics Analysis ===")

# Define consistent colors for Product_type (from previous sections)
color_map = {
    'haircare': '#ADD8E6',  # Light Blue
    'skincare': '#90EE90',  # Light Green
    'cosmetics': '#FFA500'  # Orange (if present)
}

# Chart 1: Product Sales by Product Type and Customer Demographics (Bar Chart)
sales_by_demo_product = df.groupby(['Product_type', 'Customer_demographics'])['Number_of_products_sold'].sum().reset_index()
fig_sales_demo = px.bar(sales_by_demo_product, 
                        x='Customer_demographics', 
                        y='Number_of_products_sold', 
                        color='Product_type', 
                        barmode='group',  # Group bars side by side
                        title='Product Sales by Product Type and Customer Demographics',
                        labels={'Number_of_products_sold': 'Total Units Sold', 'Customer_demographics': 'Customer Demographics'},
                        color_discrete_map=color_map)
fig_sales_demo.update_traces(marker=dict(line=dict(color='#000000', width=1)), width=0.3)
fig_sales_demo.update_layout(showlegend=True,
                             legend_title_text='Product Type',
                             xaxis_title='Customer Demographics',
                             yaxis_title='Total Units Sold',
                             bargap=0.2,
                             title_font=dict(size=16))
fig_sales_demo.show()

# Chart 2: Supplier Distribution by Customer Demographics (Bar Chart)
supplier_by_demo = df.groupby(['Supplier_name', 'Customer_demographics']).size().reset_index(name='Count')
fig_supplier_demo = px.bar(supplier_by_demo, 
                           x='Supplier_name', 
                           y='Count', 
                           color='Customer_demographics', 
                           barmode='stack',  # Stack bars for total supplier count
                           title='Supplier Distribution by Customer Demographics',
                           labels={'Count': 'Number of Products', 'Supplier_name': 'Supplier'})
fig_supplier_demo.update_traces(marker=dict(line=dict(color='#000000', width=1)))
fig_supplier_demo.update_layout(showlegend=True,
                                legend_title_text='Customer Demographics',
                                xaxis_title='Supplier',
                                yaxis_title='Number of Products',
                                bargap=0.2,
                                title_font=dict(size=16))
fig_supplier_demo.show()

# Chart 3: Revenue Distribution by Customer Demographics (Pie Chart)
revenue_by_demo = df.groupby('Customer_demographics')['Revenue_generated'].sum().reset_index()
fig_revenue_pie = px.pie(revenue_by_demo, 
                         values='Revenue_generated', 
                         names='Customer_demographics', 
                         title='Revenue Distribution by Customer Demographics',
                         color_discrete_sequence=px.colors.qualitative.Plotly,
                         hole=0.3)
fig_revenue_pie.update_traces(textinfo='percent+label', 
                              pull=[0.1] * len(revenue_by_demo), 
                              marker=dict(line=dict(color='#000000', width=2)))
fig_revenue_pie.update_layout(showlegend=True,
                              legend_title_text='Customer Demographics')
fig_revenue_pie.show()

# Chart 4: Enhanced Supplier Preference by Customer Demographics and Product Type (Grouped Bar Chart)
# Group and count products
supplier_demo_product = df.groupby(['Supplier_name', 'Customer_demographics', 'Product_type']).size().reset_index(name='Product_Count')

# Sort by Customer_demographics and Product_Count in descending order
supplier_demo_product = supplier_demo_product.sort_values(by=['Customer_demographics', 'Product_Count'], ascending=[True, False])

# Create the bar chart with descending order within each facet
fig_supplier_preference = px.bar(supplier_demo_product, 
                                 x='Supplier_name', 
                                 y='Product_Count', 
                                 color='Product_type', 
                                 facet_col='Customer_demographics',  # Separate by demographics
                                 title='Supplier Preference by Customer Demographics and Product Type ',
                                 labels={'Product_Count': 'Number of Products', 'Supplier_name': 'Supplier'},
                                 color_discrete_map=color_map,
                                 height=500,  # Increase height for better visibility
                                 text=supplier_demo_product['Product_Count'])  # Add value labels on bars
fig_supplier_preference.update_traces(marker=dict(line=dict(color='#000000', width=1)), 
                                      width=0.4,  # Slightly wider bars
                                      textposition='auto',  # Position text automatically
                                      textfont=dict(size=12))  # Readable font size
fig_supplier_preference.update_layout(showlegend=True,
                                      legend_title_text='Product Type',
                                      xaxis_title='Supplier',
                                      yaxis_title='Number of Products',
                                      bargap=0.3,  # Larger gap for clarity
                                      bargroupgap=0.1,  # Gap between groups within facets
                                      title_font=dict(size=16),
                                      font=dict(size=12),  # Consistent font size
                                      hovermode='x unified')  # Unified hover tooltip
fig_supplier_preference.update_xaxes(tickangle=45)  # Rotate x-axis labels for readability
fig_supplier_preference.show()

# %% [markdown]
# # Stock and Inventory Management

# %%
# Calculate distribution
product_type_dist = df['Product_type'].value_counts().reset_index()
product_type_dist.columns = ['Product_type', 'Count']
# Create Pie Chart
fig_pie = px.pie(product_type_dist, 
                 values='Count', 
                 names='Product_type', 
                 title='Distribution of Product Types in Inventory',
                 color_discrete_sequence=px.colors.qualitative.Plotly,  # Distinct colors
                 hole=0.3)  # Add a donut hole for style
fig_pie.update_traces(textinfo='percent+label',  # Show percentage and label
                      pull=[0.1] * len(product_type_dist),  # Pull all slices slightly
                      marker=dict(line=dict(color='#000000', width=2)))  # Add black borders for clarity
fig_pie.update_layout(showlegend=True,  # Show legend
                      legend_title_text='Product Type')
fig_pie.show()

# %%
print("\n=== Stock and Inventory Analysis ===")
df['Stock_Availability_Diff'] = df['Stock_levels'] - df['Availability']
inventory_summary = df[['SKU', 'Stock_levels', 'Availability', 'Stock_Availability_Diff', 'Order_quantities']]
display(inventory_summary.head())

# %% [markdown]
# # Supplier Analysis

# %%
print("\n=== Supplier Analysis ===")
supplier_summary = df.groupby('Supplier_name').agg({
    'Lead_time': 'mean',
    'Production_volumes': 'sum',
    'Manufacturing_costs': 'mean',
    'Defect_rates': 'mean'
}).reset_index()
display(supplier_summary)

# Interactive Scatter Plot: Lead Time vs Defect Rates
fig3 = px.scatter(supplier_summary, x='Lead_time', y='Defect_rates', size='Production_volumes', color='Supplier_name',
                  hover_data=['Supplier_name'], title='Supplier Lead Time vs Defect Rates',
                  labels={'Lead_time': 'Average Lead Time (days)', 'Defect_rates': 'Average Defect Rate (%)'})
fig3.show()

# %%
# Bar Chart: Suppliers vs Average Defect Rates
fig_supplier_bar = px.bar(supplier_summary, 
                          x='Supplier_name', 
                          y='Defect_rates', 
                          color='Supplier_name',  # Color by supplier for distinction
                          title='Average Defect Rates by Supplier',
                          labels={'Defect_rates': 'Average Defect Rate (%)', 'Supplier_name': 'Supplier'},
                          color_discrete_sequence=px.colors.qualitative.Plotly)  # Use Plotly's qualitative colors
fig_supplier_bar.update_traces(marker=dict(line=dict(color='#000000', width=1)),  # Add black borders
                               width=0.5)  # Adjust bar width
fig_supplier_bar.update_layout(showlegend=True,
                               legend_title_text='Supplier',
                               xaxis_title='Supplier',
                               yaxis_title='Average Defect Rate (%)',
                               bargap=0.2,  # Add gap between bars
                               title_font=dict(size=16))
fig_supplier_bar.show()

# %% [markdown]
# # Shipping and Logistics

# %%
print("\n=== Shipping and Logistics Analysis ===")
shipping_summary = df.groupby('Shipping_carriers').agg({
    'Shipping_times': 'sum',
    'Shipping_costs': 'sum',
    'Costs': 'sum'  # Transportation costs
}).reset_index()
display(shipping_summary)

# Interactive Bar Plot: Shipping Costs by Carrier
fig4 = px.bar( shipping_summary,
              x='Shipping_carriers',
              y='Shipping_costs',
              color='Shipping_carriers',
              title='Total Shipping Costs by Carrier',
              labels={'Shipping_costs': 'Shipping Costs ($)'}
)

# Reduce bar width
fig4.update_traces(width=0.4)  # Default is 0.8, you can try 0.3–0.5 for slim bars

fig4.show()


# %% [markdown]
# # Analyzing SKU's

# %%
rev_chart = px.line(df, x='SKU', y='Revenue_generated', title='Revenue Generated by SKU',
                    labels={'Revenue_generated': 'Revenue Generated ($)', 'SKU': 'SKU'},
                    color='Product_type',  # Color by Product Type
                    color_discrete_map=color_map)  # Apply custom colors
rev_chart.update_traces(mode='lines+markers', marker=dict(size=6, line=dict(width=1, color='#000000')))  # Add markers and borders
rev_chart.update_layout(showlegend=True, 
                         legend_title_text='Product Type',
                         xaxis_title='SKU',
                         yaxis_title='Revenue Generated ($)',
                         title_font=dict(size=16))
rev_chart.show()

# %%
stock_chart = px.line(df, x='SKU', y='Stock_levels', title='Stock Levels by SKU',
                     labels={'Stock_levels': 'Stock Levels', 'SKU': 'SKU'},
                     color='Product_type',  # Color by Product Type
                     color_discrete_map=color_map)  # Apply custom colors
stock_chart.update_traces(mode='lines+markers', marker=dict(size=6, line=dict(width=1, color='#000000')))  # Add markers and borders
stock_chart.update_layout(showlegend=True, 
                          legend_title_text='Product Type',
                          xaxis_title='SKU',
                          yaxis_title='Stock Levels',
                          title_font=dict(size=16))
stock_chart.show()

# %%
# Order quantities chart
order_chart = px.line(df, x='SKU', y='Order_quantities', title='Order Quantities by SKU',
                       labels={'Order_quantities': 'Order Quantities', 'SKU': 'SKU'},
                       color='Product_type',  # Color by Product Type
                       color_discrete_map=color_map)  # Apply custom colors
order_chart.update_traces(mode='lines+markers', marker=dict(size=6, line=dict(width=1, color='#000000')))  # Add markers and borders
order_chart.update_layout(showlegend=True, 
                           legend_title_text='Product Type',
                           xaxis_title='SKU',
                           yaxis_title='Order Quantities',
                           title_font=dict(size=16))
order_chart.show()

# %% [markdown]
# # Cost Analysis

# %%
# Shipping Costs by carrier chart
shipping_cost_chart = px.bar(df, 
    x='Shipping_carriers', 
    y='Shipping_costs', 
    title='Total Shipping Costs by Carrier',
    labels={'Shipping_costs': 'Shipping Costs ($)', 'Shipping_carriers': 'Shipping Carrier'},
    color='Shipping_carriers',  # Color by Shipping Carrier
    color_discrete_map=color_map  # Apply custom colors
)
shipping_cost_chart.update_traces(width=0.4)  # Reduce bar width for better visibility
                             
shipping_cost_chart.show()

# %%
# Transportation Costs by carrier chart
transportation_cost_chart = px.pie(df,
                                   values='Costs',
                                   names='Transportation_modes',
                                   title='Transportation Costs by Mode',
                                   hole=0.5,  # Donut style for visual appeal
                                   color_discrete_sequence=px.colors.qualitative.Plotly,  # Distinct colors
                                   labels={'Costs': 'Transportation Costs ($)', 'Transportation_modes': 'Transportation Mode'}
                                      )

# Reduce bar width for better visibility
transportation_cost_chart.show()

# %%
# --- Inventory Turnover Ratio Calculation ---
print("\n=== Inventory Turnover Ratio Calculation ===")
df['Inventory_Turnover_Ratio'] = df['Number_of_products_sold'] / df['Stock_levels']
inventory_turnover_summary = df[['SKU', 'Product_type', 'Number_of_products_sold', 'Stock_levels', 'Inventory_Turnover_Ratio']]

# Sort by Product_type and then Inventory_Turnover_Ratio in descending order
inventory_turnover_summary = inventory_turnover_summary.sort_values(by=['Product_type', 'Inventory_Turnover_Ratio'], ascending=[True, False])
display(inventory_turnover_summary.head())  # Display the first few rows for verification

# Creating a colormap for consistent colors for Product_type
color_map = {
    'haircare': '#ADD8E6',  # Light Blue
    'skincare': '#90EE90',  # Light Green
    'cosmetics': '#FFA500'  # Orange (if present)
}

# Interactive Bar Plot: Inventory Turnover Ratio by Product Type
fig_inventory_turnover = px.bar(inventory_turnover_summary,
                                x='SKU',
                                y='Inventory_Turnover_Ratio',
                                color='Product_type',
                                title='Inventory Turnover Ratio by SKU ',
                                labels={'Inventory_Turnover_Ratio': 'Inventory Turnover Ratio', 'SKU': 'SKU'},
                                color_discrete_map=color_map,  # Apply custom colors
                                category_orders={'Product_type': ['haircare', 'skincare', 'cosmetics']})  # Order Product_type
fig_inventory_turnover.update_traces(width=0.4,  # Reduce bar width for better visibility
                                     marker=dict(line=dict(color='#000000', width=1)))  # Add borders
fig_inventory_turnover.update_layout(showlegend=True,
                                     legend_title_text='Product Type',
                                     xaxis_title='SKU',
                                     yaxis_title='Inventory Turnover Ratio',
                                     title_font=dict(size=16),
                                     bargap=0.2)  # Add gap between bars for clarity
fig_inventory_turnover.show()

# %% [markdown]
# # Quality Control

# %%
print("\n=== Quality Control Analysis ===")
quality_summary = df[['SKU', 'Inspection_results', 'Defect_rates']]
display(quality_summary.head())  # Display the first few rows for verification


# %% [markdown]
# ####

# %%
# Pie Chart 1: Defect Rates by Mode of Transportation
transport_defects = df.groupby('Transportation_modes')['Defect_rates'].mean().reset_index()
fig_transport_pie = px.pie(transport_defects, 
                           values='Defect_rates', 
                           names='Transportation_modes', 
                           title='Average Defect Rates by Mode of Transportation',
                           color_discrete_sequence=px.colors.qualitative.Plotly,
                           hole=0.3)  # Donut style
fig_transport_pie.update_traces(textinfo='percent+label', 
                                pull=[0.1] * len(transport_defects), 
                                marker=dict(line=dict(color='#000000', width=2)))
fig_transport_pie.update_layout(showlegend=True, 
                                legend_title_text='Transportation Mode')
fig_transport_pie.show()

# Pie Chart 2: Defect Rates by Product Type
product_type_defects = df.groupby('Product_type')['Defect_rates'].mean().reset_index()
fig_product_type_pie = px.pie(product_type_defects, 
                              values='Defect_rates', 
                              names='Product_type', 
                              title='Average Defect Rates by Product Type',
                              color='Product_type',
                              color_discrete_map={
                                  'haircare': '#ADD8E6',  # Light Blue
                                  'skincare': '#90EE90',  # Light Green
                                  'cosmetics': '#FFA500'  # Orange (if present)
                              },
                              hole=0.3)
fig_product_type_pie.update_traces(textinfo='percent+label', 
                                   pull=[0.1] * len(product_type_defects), 
                                   marker=dict(line=dict(color='#000000', width=2)))
fig_product_type_pie.update_layout(showlegend=True, 
                                   legend_title_text='Product Type')
fig_product_type_pie.show()

# Bar Chart: Top 3 Most Defective vs Bottom 3 Least Defective SKUs
defect_sorted = df[['SKU', 'Defect_rates']].sort_values(by='Defect_rates', ascending=False)
top_3_defective = defect_sorted.head(3)
bottom_3_defective = defect_sorted.tail(3)
combined_defective = pd.concat([top_3_defective, bottom_3_defective])

fig_defective_bar = px.bar(combined_defective, 
                           x='SKU', 
                           y='Defect_rates', 
                           title='Top 3 Most Defective vs Bottom 3 Least Defective SKUs',
                           labels={'Defect_rates': 'Defect Rate (%)'},
                           color='Defect_rates',  # Gradient based on value
                           color_continuous_scale='Viridis')  # High = yellow, Low = purple
fig_defective_bar.update_traces(marker=dict(line=dict(color='#000000', width=1)))
fig_defective_bar.update_layout(showlegend=False,  # No legend for continuous scale
                                xaxis_title='SKU',
                                yaxis_title='Defect Rate (%)')
fig_defective_bar.show()


