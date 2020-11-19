CLASS ztest_abap_git DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS test_ci.
    METHODS addition IMPORTING iv_num1          TYPE i
                               iv_num2          TYPE i
                     RETURNING VALUE(rv_result) TYPE i.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ztest_abap_git IMPLEMENTATION.
  METHOD test_ci.

  ENDMETHOD.

  METHOD addition.

    rv_result = iv_num1 + iv_num2.

"check this.
"class. method

		

  ENDMETHOD.

ENDCLASS.
