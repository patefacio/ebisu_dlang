module forecast.income_expense_model;

import opmix.mix;
import std.datetime;
debug import std.stdio;

/**
   Differentiate between income and expense items
*/
enum IncomeExpenseType { 
  Income,
  Expense
}
struct ModeledItemSpec { 
  mixin ReadOnly!_label;
  mixin ReadOnly!_type;
  mixin ReadOnly!_growthRate;
  /**
     Slices of modeled item spec - See blah-bahdee-blah
  */
  alias immutable(ModeledItemSpec)[] ModeledItemSpecArr;
  private {
    /**
       Describes item
    */
    string _label;
    /**
       I/E
    */
    IncomeExpenseType _type;
    double _growthRate = 3.0;
  }
}
static if(1) unittest { 
  // custom <unittest income_expense_model>
  // end <unittest income_expense_model>
}
