*"* use this source file for your ABAP unit test classes
CLASS ltc_test_class DEFINITION
  FINAL
  FOR TESTING
  RISK LEVEL HARMLESS
  DURATION SHORT  .

  PUBLIC SECTION.
    METHODS test_meth_test_ci.
    METHODS addition.

ENDCLASS.

CLASS ltc_test_class IMPLEMENTATION.

  METHOD test_meth_test_ci.

    NEW ztest_abap_git( )->test_ci( ).


  ENDMETHOD.

  METHOD addition.

    "when then
    cl_abap_unit_assert=>assert_equals(  act                  = NEW ztest_abap_git( )->addition( iv_num1   = 1
                                                                                                 iv_num2   = 2 )
                                         exp                  = 4
                                         quit                 = if_abap_unit_constant=>quit-test ).



  ENDMETHOD.

ENDCLASS.
