class zcl_asset_validation definition
  public
  final
  create private

  global friends cl_mpa_asset_process_factory .

  public section.

    interfaces if_mpa_asset_validate .

    types:
      begin of gty_s_row_numbers.
    types row type i.
    types end of gty_s_row_numbers .
    types:
      gty_t_range_fieldname type range of fieldname .
    types:
      gty_t_row_number      type standard table of gty_s_row_numbers with empty key .

    constants gc_sign_exclude type char1 value 'E' ##NO_TEXT.   "Range Sign
    constants gc_sign_include type char1 value 'I' ##NO_TEXT.   "Range Sign
    constants gc_option_not_equal type char2 value 'NE' ##NO_TEXT. "Range Option
    constants gc_option_equal type char2 value 'EQ' ##NO_TEXT.  "Range Option
    constants:
      "! Fields for validation
      begin of gc_field_name,
        slno          type fieldname value 'SLNO',

        status        type fieldname value 'STATUS',
        "Company code
        bukrs         type fieldname value 'BUKRS',
        "Target Company code
        pbukrs        type fieldname value 'PBUKRS',
        "Asset Class
        anlkl         type fieldname value 'ANLKL',
        "Finance ledger
        fins_ledger_1 type fieldname value 'FINS_LEDGER_1',
        "Finance ledger
        fins_ledger_2 type fieldname value 'FINS_LEDGER_2',
        "Finance ledger
        fins_ledger_3 type fieldname value 'FINS_LEDGER_3',
        "Finance ledger
        fins_ledger_4 type fieldname value 'FINS_LEDGER_4',
        "Finance ledger
        fins_ledger_5 type fieldname value 'FINS_LEDGER_5',
        "Depreciation Area Real or Derived
        afaber_1      type fieldname value 'AFABER_1',
        "Depreciation Area Real or Derived
        afaber_2      type fieldname value 'AFABER_2',
        "Depreciation Area Real or Derived
        afaber_3      type fieldname value 'AFABER_3',
        "Depreciation Area Real or Derived
        afaber_4      type fieldname value 'AFABER_4',
        "Depreciation Area Real or Derived
        afaber_5      type fieldname value 'AFABER_5',
        "Asset number
        anln1         type fieldname value 'ANLN1',
        "Target Asset number
        panl1         type fieldname value 'PANL1',
        "Asset Sub-number
        anln2         type fieldname value 'ANLN2',
        "Target Asset Sub-number
        panl2         type fieldname value 'PANL2',
        "Cost Center
        kostl         type fieldname value 'KOSTL',
        "Base Unit of Measure
        meins         type fieldname value 'MEINS',
        "Currency Key
        waers         type fieldname value 'WAERS',
        "Fiscal Period
        monat         type fieldname value 'MONAT',
        "Date for Beginning of Validity
        adatu_1       type fieldname value 'ADATU_1',
        "Date for Beginning of Validity
        adatu_2       type fieldname value 'ADATU_2',
        "Date for Beginning of Validity
        adatu_3       type fieldname value 'ADATU_3',
        "Date for Beginning of Validity
        adatu_4       type fieldname value 'ADATU_4',
        "Date for Beginning of Validity
        adatu_5       type fieldname value 'ADATU_5',
        "Asset's Country of Origin
        am_land1      type fieldname value 'AM_LAND1',
        "Plant
        werks_d       type fieldname value 'WERKS_D',
        "Company ID of trading partner
        rassc         type fieldname value 'RASSC',
        "Accounting Principle
        acc_principle type fieldname value 'ACC_PRINCIPLE',
        "Transfer Variant
        trava         type fieldname value 'TRAVA',
        "Document type
        blart         type fieldname value 'BLART',
        "Recovery Indicator
        recid         type  fieldname value 'RECID',
      end of gc_field_name .
    constants:
      "! Validation fields type
      begin of gc_field_type,
        bukrs         type fieldname value 'BUKRS',
        pbukrs        type fieldname value 'BF_PBUKR',
        anlkl         type fieldname value 'ANLKL',
        fins_ledger   type fieldname value 'FINS_LEDGER',
        afaber        type fieldname value 'AFABER',
        anln1         type fieldname value 'ANLN1',
        anln2         type fieldname value 'ANLN2',
        panl1         type fieldname value 'BF_PANL1',
        panl2         type fieldname value 'BF_PANL2',
        kostl         type fieldname value 'KOSTL',
        meins         type fieldname value 'MEINS',
        waers         type fieldname value 'WAERS',
        monat         type fieldname value 'MONAT',
        adatu         type fieldname value 'ADATU',
        am_land1      type fieldname value 'AM_LAND1',
        werks_d       type fieldname value 'WERKS_D',
        rassc         type fieldname value 'RASSC',
        acc_principle type fieldname value 'ACCOUNTING_PRINCIPLE',
        trava         type fieldname value 'TRANSVAR',
        blart         type fieldname value 'BLART',
        recid         type fieldname value 'JV_RECIND',
      end of gc_field_type .
private section.

    "Check processing mass transfer scenario then enable flag
  data MV_MPA_MT type BOOLEAN .

      "! <p class="shorttext synchronized" lang="en">Change internal table status and build summary message</p>
      "!
      "! @parameter io_mpa_output | <p class="shorttext synchronized" lang="en">Output handler instance</p>
      "! @parameter it_invalid_row | <p class="shorttext synchronized" lang="en">Table with row index for which the asset validation failed</p>
      "! @parameter ct_mpa_asset_data | <p class="shorttext synchronized" lang="en">Asset data</p>
  methods CHANGE_ITAB_STATUS_BUILD_SMMRY
    importing
      !IO_MPA_OUTPUT type ref to IF_MPA_OUTPUT
      !IT_INVALID_ROW type GTY_T_ROW_NUMBER
    changing
      !CT_MPA_ASSET_DATA type ANY TABLE .
      "! <p class="shorttext synchronized" lang="en">Get name range of all the fields that need to be validated</p>
      "!
      "! @parameter rt_range_fieldname | <p class="shorttext synchronized" lang="en">range table of field names maintained</p>
  methods GET_VALIDATING_FIELDNAMES
    returning
      value(RT_RANGE_FIELDNAME) type GTY_T_RANGE_FIELDNAME .
ENDCLASS.



CLASS zcl_asset_validation IMPLEMENTATION.


  method if_mpa_asset_validate~validate.

    data : lo_table_descr type ref to cl_abap_tabledescr,
           lo_line_type   type ref to cl_abap_datadescr,
           lo_struct      type ref to cl_abap_structdescr,
           lv_line_count  type i value 0.

    lo_table_descr ?=  cl_abap_typedescr=>describe_by_data( ct_mpa_asset_data ).
    lo_line_type = lo_table_descr->get_table_line_type( ).

    mv_mpa_mt = cond #( when lo_line_type->get_relative_name( ) = if_mpa_output=>gc_mpa_struc-transfer
                        then abap_true ).

    lo_struct ?= lo_line_type.

    loop at lo_struct->components assigning field-symbol(<lv_component>) where name in get_validating_fieldnames( ).

      loop at ct_mpa_asset_data assigning field-symbol(<ls_asset_row_data>).
        lv_line_count += 1.

        assign component gc_field_name-status of structure <ls_asset_row_data> to field-symbol(<lv_asset_field_data>).

        "only consider the rows which where not successful in earlier runs
        if <lv_asset_field_data> is initial.

          assign component <lv_component>-name of structure <ls_asset_row_data> to <lv_asset_field_data>.

          if <lv_asset_field_data> is not initial.
            lcl_field=>get_field_instance( lo_struct->get_component_type( <lv_component>-name )->get_relative_name( ) )->insert( iv_index = lv_line_count
                                                                                                                                 iv_value = <lv_asset_field_data>
                                                                                                                                 io_mpa_output   =  io_mpa_output ).
          endif.

        endif.

      endloop.
      clear lv_line_count.

    endloop.

    data(lt_invalid_row_numbers) = lcl_field=>validate_fields( exporting io_mpa_output     = io_mpa_output
                                                               changing  ct_mpa_asset_data = ct_mpa_asset_data ).

    "save message into application log - for scenarios using commit per row
*    if iv_write_into_applog = abap_true.
*
*      io_mpa_output->save_app_log_message( abap_true ).
*
*    endif.

    me->change_itab_status_build_smmry( exporting io_mpa_output     = io_mpa_output
                                       it_invalid_row    = lt_invalid_row_numbers
                             changing  ct_mpa_asset_data = ct_mpa_asset_data ).

  endmethod.


  method get_validating_fieldnames.

    rt_range_fieldname = value #( ( sign = gc_sign_include
                                    option = gc_option_equal
                                    low = gc_field_name-bukrs )
                                  ( sign = gc_sign_include
                                    option = gc_option_equal
                                    low = gc_field_name-pbukrs )
                                  ( sign = gc_sign_include
                                    option = gc_option_equal
                                    low = gc_field_name-anlkl )
                                  ( sign = gc_sign_include
                                    option = gc_option_equal
                                    low = gc_field_name-fins_ledger_1 )
                                  ( sign = gc_sign_include
                                    option = gc_option_equal
                                    low = gc_field_name-fins_ledger_2 )
                                  ( sign = gc_sign_include
                                    option = gc_option_equal
                                    low = gc_field_name-fins_ledger_3 )
                                  ( sign = gc_sign_include
                                    option = gc_option_equal
                                    low = gc_field_name-fins_ledger_4 )
                                  ( sign = gc_sign_include
                                    option = gc_option_equal
                                    low = gc_field_name-fins_ledger_5 )
                                  ( sign = gc_sign_include
                                    option = gc_option_equal
                                    low = gc_field_name-afaber_1 )
                                  ( sign = gc_sign_include
                                    option = gc_option_equal
                                    low = gc_field_name-afaber_2 )
                                  ( sign = gc_sign_include
                                    option = gc_option_equal
                                    low = gc_field_name-afaber_3 )
                                  ( sign = gc_sign_include
                                    option = gc_option_equal
                                    low = gc_field_name-afaber_4 )
                                  ( sign = gc_sign_include
                                    option = gc_option_equal
                                    low = gc_field_name-afaber_5 )
                                  ( sign = gc_sign_include
                                    option = gc_option_equal
                                    low = gc_field_name-anln1 )
                                  ( sign = gc_sign_include
                                    option = gc_option_equal
                                    low = gc_field_name-panl1 )
                                  ( sign = gc_sign_include
                                    option = gc_option_equal
                                    low = gc_field_name-anln2 )
                                  ( sign = gc_sign_include
                                    option = gc_option_equal
                                    low = gc_field_name-panl2 )
                                  ( sign = gc_sign_include
                                    option = gc_option_equal
                                    low = gc_field_name-kostl )
                                  ( sign = gc_sign_include
                                    option = gc_option_equal
                                    low = gc_field_name-meins )
                                  ( sign = gc_sign_include
                                    option = gc_option_equal
                                    low = gc_field_name-waers )
                                  ( sign = gc_sign_include
                                    option = gc_option_equal
                                    low = gc_field_name-monat )
                                  ( sign = gc_sign_include
                                    option = gc_option_equal
                                    low = gc_field_name-adatu_1 )
                                  ( sign = gc_sign_include
                                    option = gc_option_equal
                                    low = gc_field_name-adatu_2 )
                                  ( sign = gc_sign_include
                                    option = gc_option_equal
                                    low = gc_field_name-adatu_3 )
                                  ( sign = gc_sign_include
                                    option = gc_option_equal
                                    low = gc_field_name-adatu_4 )
                                  ( sign = gc_sign_include
                                    option = gc_option_equal
                                    low = gc_field_name-adatu_5 )
                                  ( sign = gc_sign_include
                                    option = gc_option_equal
                                    low = gc_field_name-am_land1 )
                                  ( sign = gc_sign_include
                                    option = gc_option_equal
                                    low = gc_field_name-werks_d )
                                  ( sign = gc_sign_include
                                    option = gc_option_equal
                                    low = gc_field_name-rassc )
                                  ( sign = gc_sign_include
                                    option = gc_option_equal
                                    low = gc_field_name-acc_principle )
                                  ( sign = gc_sign_include
                                    option = gc_option_equal
                                    low = gc_field_name-trava )
                                  ( sign = gc_sign_include
                                    option = gc_option_equal
                                    low = gc_field_name-blart )
                                  ( sign = gc_sign_include
                                    option = gc_option_equal
                                    low = gc_field_name-recid )  ).

  endmethod.


  method change_itab_status_build_smmry.

    loop at ct_mpa_asset_data assigning field-symbol(<ls_asset_data>).

      assign component 2 of structure <ls_asset_data> to field-symbol(<lv_asset_status>).

      if line_exists( it_invalid_row[ row = sy-tabix ] ) or <lv_asset_status> = if_mpa_output=>gc_msg_type-success.

        <lv_asset_status> = cond #( when <lv_asset_status> = if_mpa_output=>gc_msg_type-success "successfully processed row from earlier run
                                    then if_mpa_output=>gc_msg_type-success
                                    else if_mpa_output=>gc_msg_type-error ).

        assign component gc_field_name-slno of structure <ls_asset_data> to field-symbol(<lv_slno>).
        assign component gc_field_name-bukrs of structure <ls_asset_data> to field-symbol(<lv_bukrs>).
        assign component gc_field_name-anln1 of structure <ls_asset_data> to field-symbol(<lv_anln1>).
        assign component gc_field_name-anln2 of structure <ls_asset_data> to field-symbol(<lv_anln2>).
        assign component gc_field_name-pbukrs of structure <ls_asset_data> to field-symbol(<lv_pbukrs>).
        assign component gc_field_name-panl1 of structure <ls_asset_data> to field-symbol(<lv_panl1>).
        assign component gc_field_name-panl2 of structure <ls_asset_data> to field-symbol(<lv_panl2>).

        io_mpa_output->add_summary_message( is_message = value #( slno = <lv_slno> "sy-tabix
                                                                  status = conv #( <lv_asset_status> )
                                                                  bukrs = cond #( when <lv_bukrs> is assigned
                                                                                  then <lv_bukrs>
                                                                                  else abap_false )
                                                                  anln1 = cond #( when <lv_anln1> is assigned
                                                                                  then <lv_anln1>
                                                                                  else abap_false )
                                                                  anln2 = cond #( when <lv_anln2> is assigned
                                                                                  then <lv_anln2>
                                                                                  else abap_false )
                                                                  pbukrs = cond #( when <lv_pbukrs> is assigned
                                                                                  then <lv_pbukrs>
                                                                                  else abap_false )
                                                                  panl1 = cond #( when <lv_panl1> is assigned
                                                                                  then <lv_panl1>
                                                                                  else abap_false )
                                                                  panl2 = cond #( when <lv_panl2> is assigned
                                                                                  then <lv_panl2>
                                                                                  else abap_false )
                                                                  msgtxt = cond #( when <lv_asset_status> = if_mpa_output=>gc_msg_type-error
                                                                                   then 'Validation failed !'(001)
                                                                                   else 'Asset processed successfuly'(002) ) ) ).

      endif.

    endloop.

  endmethod.
ENDCLASS.
