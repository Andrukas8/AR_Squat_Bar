//+------------------------------------------------------------------+
//|                                         AR_Squat_Bar.mq5         |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Andrukas8"
#property link      "https://github.com/Andrukas8/AR_Squat_Bar"
#property version   "1.02"
#property indicator_chart_window

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot UP
#property indicator_label1  "Up"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrLimeGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot DN
#property indicator_label2  "Down"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrTomato
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2

// -- indicator inputs
input double close_range = 0.5; // Close Range

//--- indicator buffers
double BufferUP[];
double BufferDN[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferUP,INDICATOR_DATA);
   SetIndexBuffer(1,BufferDN,INDICATOR_DATA);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW

   PlotIndexSetInteger(0,PLOT_ARROW,225); // Arrow up
   PlotIndexSetInteger(1,PLOT_ARROW,226); // Arrow Down

   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,-50);
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,50);

//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"SquatBar");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferUP,true);
   ArraySetAsSeries(BufferDN,true);

//---
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- Checking the minimum number of bars for calculation

   if(rates_total<3)
      return 0;

//--- Checking and calculating the number of bars
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-5;
      ArrayInitialize(BufferUP,EMPTY_VALUE);
      ArrayInitialize(BufferDN,EMPTY_VALUE);
     }
//--- Indexing arrays as timeseries
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(close,true);

//--- Calculating the indicator

   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      bool strike_up=false;
      bool strike_dn=false;
      double mfi_curr = (high[i] - low[i]) / tick_volume[i];
      double mfi_prev = (high[i+1] - low[i+1]) / tick_volume[i+1];

      if(low[i] < low[i+1] && close[i] > high[i] - (high[i] - low[i])*close_range && mfi_curr < mfi_prev && tick_volume[i] > tick_volume[i+1])
         strike_up = true;

      if(high[i] > high[i+1] && close[i] < low[i] + (high[i] - low[i])*close_range && mfi_curr < mfi_prev && tick_volume[i] > tick_volume[i+1])
         strike_dn = true;

      if(strike_up)
         BufferUP[i]=close[i];
      else
         BufferUP[i]=EMPTY_VALUE;

      if(strike_dn)
         BufferDN[i]=close[i];
      else
         BufferDN[i]=EMPTY_VALUE;
     }

//--- return value of prev_calculated for next call
   return(rates_total);

  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+