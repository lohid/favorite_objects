*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
class ltc_mpa_asset_validate_dummy definition deferred.

class lcl_field definition abstract create protected friends ltc_mpa_asset_validate_dummy.
  public section.

    class-methods: get_field_instance
      importing iv_data_type     type any
      returning value(ro_result) type ref to lcl_field,
      validate_fields importing io_mpa_output                type ref to if_mpa_output
                      changing  ct_mpa_asset_data            type any table
                      returning value(rt_invalid_row_number) type cl_mpa_asset_validate=>gty_t_row_number .

    methods: validate abstract importing io_mpa_output               type ref to if_mpa_output
                               returning value(rt_invalid_row_index) type cl_mpa_asset_validate=>gty_t_row_number,
      insert abstract importing iv_index                type i
                                iv_value                type any
                                io_mpa_output           type ref to if_mpa_output
                      returning value(rv_insert_failed) type abap_bool.

  protected section.

    data : mo_faa_md_data_access type ref to if_faa_md_data_access,
           mo_faa_cfg_access     type ref to if_faa_cfg_access.

    methods constructor.

  private section.

    class-data: gt_fields                  type standard table of ref to lcl_field , "WITH KEY TABLE_LINE.
                go_faa_md_data_access_fake type ref to if_faa_md_data_access,
                go_faa_cfg_access_fake     type ref to if_faa_cfg_access.
endclass.

class ltc_bukrs definition deferred.
class lcl_bukrs definition final inheriting from lcl_field friends ltc_bukrs.

  public section.
    class-methods get_instance returning value(ro_result) type ref to lcl_bukrs.
    types gty_tt_range_bukrs type range of bukrs.
    methods: validate redefinition,
      insert redefinition,
      get_range returning value(rt_bukrs_range) type gty_tt_range_bukrs,
      get_value importing iv_index        type i
                returning value(rv_bukrs) type bukrs.

  private section.

    types begin of gty_st_index_bukrs.
    types index type i .
    types bukrs type bukrs.
    types end of gty_st_index_bukrs.
    types gty_tt_index_bukrs type standard table of gty_st_index_bukrs with default key.

    class-data: lo_instance type ref to lcl_bukrs.

    data : mt_bukrs       type gty_tt_index_bukrs,
           mt_bukrs_range type gty_tt_range_bukrs.

    methods create_bukrs_range returning value(rt_bukrs_range) type gty_tt_range_bukrs.

endclass.

class lcl_bukrs implementation.

  method get_instance.

    lo_instance = cond #( when lo_instance is bound
                          then lo_instance
                          else new lcl_bukrs( ) ).

    ro_result = lo_instance.

  endmethod.

  method get_range.

    rt_bukrs_range = cond #( when mt_bukrs_range is not initial
                             then mt_bukrs_range
                             else create_bukrs_range( ) ).

  endmethod.


  method insert.

    insert value #( index = iv_index
                    bukrs =   |{ iv_value alpha = in }| ) into table mt_bukrs.

  endmethod.

  method validate.

    mo_faa_cfg_access->get_faa_cfg_cmp_multiple(
      exporting
        it_range_comp_code = get_range( )
      importing
        et_faa_cfg_cmp     = data(et_faa_cfg_cmp)
  exceptions
    not_found          = 1
    others             = 2  ).

    if sy-subrc <> 0.
      io_mpa_output->add_app_log_message( iv_msgid   = sy-msgid
                                          iv_msgty   = sy-msgty
                                          iv_msgno   = sy-msgno
                                          iv_msgv1   = sy-msgv1
                                          iv_msgv2   = sy-msgv2
                                          iv_msgv3   = sy-msgv3
                                          iv_msgv4   = sy-msgv4 ).
    else.

      loop at mt_bukrs reference into data(lr_bukrs).

        if line_exists( et_faa_cfg_cmp[ comp_code = lr_bukrs->bukrs ] ).
          "do nothing
        else.

          io_mpa_output->add_app_log_message( exporting iv_row = lr_bukrs->index
                                                        iv_msgno   = 150
                                                        iv_msgty   = if_mpa_output=>gc_msg_type-error
                                                        iv_msgv1   = lr_bukrs->bukrs ).

          append value #( row = lr_bukrs->index ) to rt_invalid_row_index.

        endif.

      endloop.

    endif.
  endmethod.

  method create_bukrs_range.

    loop at mt_bukrs reference into data(lr_bukrs).
      append value #( sign = cl_mpa_asset_validate=>gc_sign_include
                      option = cl_mpa_asset_validate=>gc_option_equal
                      low = lr_bukrs->bukrs ) to rt_bukrs_range .
    endloop.

  endmethod.


  method get_value.

    rv_bukrs = cond #( when line_exists( mt_bukrs[ index = iv_index ] )
                       then mt_bukrs[ index = iv_index ]-bukrs ) .

  endmethod.

endclass.

class ltc_trava definition deferred.
class lcl_trava definition final inheriting from lcl_field friends ltc_trava.

  public section.

    class-methods get_instance
      returning value(ro_result) type ref to lcl_trava.

    methods:
      validate redefinition,
      insert redefinition.

  private section.

    types : begin of gty_st_index_trava,
              index type i,
              trava type transvar,
            end of gty_st_index_trava.

    types gty_tt_index_trava type standard table of gty_st_index_trava with default key.

    class-data: lo_instance type ref to lcl_trava.

    data : mt_trava type gty_tt_index_trava.

endclass.

class lcl_trava implementation.

  method get_instance.

    lo_instance = cond #( when lo_instance is bound
                          then lo_instance
                          else new lcl_trava( ) ).

    ro_result = lo_instance.

  endmethod.

  method insert.

    insert value #( index = iv_index
                    trava = |{ iv_value alpha = in }| ) into table mt_trava.

  endmethod.

  method validate.

    types : begin of lty_st_trava,
              trava type transvar,
            end of lty_st_trava.

    types lty_tt_trava type standard table of lty_st_trava with default key.

    data(lt_trava) =  value lty_tt_trava(
      "For Inter-company asset transfers (different company codes):
                           ( trava = '0001' )
                           ( trava = '0002' )
                           ( trava = '0003' )
                           ( trava = '0007' )
                           ( trava = '0008' )
      "For intra-company asset transfers (same company code)
                           ( trava = '0004' )  ).

    loop at mt_trava reference into data(lr_trava).

      read table lt_trava assigning field-symbol(<ls_trava>) with key trava = lr_trava->trava.
      if sy-subrc is not initial.
        io_mpa_output->add_app_log_message(   exporting iv_row = lr_trava->index
                                                        iv_msgno   = 169
                                                        iv_msgty   = if_mpa_output=>gc_msg_type-error
                                                  iv_msgv1   = lr_trava->trava ).

        append value #( row = lr_trava->index ) to rt_invalid_row_index.
      endif.

    endloop.

  endmethod.

endclass.

class ltc_blart definition deferred.
class lcl_blart definition final inheriting from lcl_field friends ltc_blart.

  public section.

    class-methods get_instance
      returning value(ro_result) type ref to lcl_blart.

    methods:
      validate redefinition,
      insert redefinition.

  private section.

    types : begin of gty_st_index_blart,
              index type i,
              blart type blart,
            end of gty_st_index_blart.

    types gty_tt_index_blart type standard table of gty_st_index_blart with default key.

    class-data: lo_instance type ref to lcl_blart.

    data : mt_blart type gty_tt_index_blart.

endclass.

class lcl_blart implementation.

  method get_instance.

    lo_instance = cond #( when lo_instance is bound
                          then lo_instance
                          else new lcl_blart( ) ).

    ro_result = lo_instance.

  endmethod.

  method insert.

    insert value #( index = iv_index
                    blart =  |{ iv_value alpha = in }| ) into table mt_blart.

  endmethod.

  method validate.

    if ( mt_blart[] is not initial ).

      select blart from t003 into table @data(lt_t003)
          for all entries in @mt_blart where blart = @mt_blart-blart.

    endif.

    loop at mt_blart reference into data(lr_blart).

      read table lt_t003 assigning field-symbol(<ls_t003>) with key blart = lr_blart->blart.
      if sy-subrc is not initial.
        io_mpa_output->add_app_log_message( exporting iv_row = lr_blart->index
                                                      iv_msgno   = 170
                                                      iv_msgty   = if_mpa_output=>gc_msg_type-error
                                                      iv_msgv1   = lr_blart->blart ).

        append value #( row = lr_blart->index ) to rt_invalid_row_index.
      endif.

    endloop.

  endmethod.

endclass.

class ltc_recid definition deferred.
class lcl_recid definition final inheriting from lcl_field friends ltc_recid.

  public section.

    class-methods get_instance
      returning value(ro_result) type ref to lcl_recid.

    methods:
      validate redefinition,
      insert redefinition.

  private section.

    types : begin of gty_st_index_recid,
              index type i,
              bukrs type bukrs,
              recid type jv_recind,
            end of gty_st_index_recid.

    types gty_tt_index_recid type standard table of gty_st_index_recid with default key.

    class-data: lo_instance type ref to lcl_recid.

    data : mt_recid type gty_tt_index_recid.

endclass.

class lcl_recid implementation.

  method get_instance.

    lo_instance = cond #( when lo_instance is bound
                          then lo_instance
                          else new lcl_recid( ) ).

    ro_result = lo_instance.

  endmethod.

  method insert.

    insert value #( index = iv_index
                    recid =  |{ iv_value alpha = in }|
                    bukrs = lcl_bukrs=>get_instance( )->get_value( iv_index = iv_index ) ) into table mt_recid.

  endmethod.

  method validate.

    if ( mt_recid[] is not initial ).
      select bukrs,recid  from t8jj into table @data(lt_t8jj)
          for all entries in @mt_recid where recid = @mt_recid-recid
          and bukrs = @mt_recid-bukrs.
    endif.

    loop at mt_recid reference into data(lr_recid).

      read table lt_t8jj assigning field-symbol(<ls_t8jj>) with key bukrs = lr_recid->bukrs
                                                                    recid = lr_recid->recid.
      if sy-subrc is not initial.
        io_mpa_output->add_app_log_message( exporting iv_row = lr_recid->index
                                                      iv_msgno   = 171
                                                      iv_msgty   = if_mpa_output=>gc_msg_type-error
                                                      iv_msgv1   = lr_recid->recid
                                                      iv_msgv2   = lr_recid->bukrs ).

        append value #( row = lr_recid->index ) to rt_invalid_row_index.
      endif.

    endloop.

  endmethod.

endclass.

class lcl_anlkl definition final inheriting from lcl_field.

  public section.
    class-methods get_instance returning value(ro_result) type ref to lcl_anlkl.
    methods: validate redefinition,
      insert redefinition.

  private section.

    types begin of gty_st_index_anlkl.
    types index type i .
    types anlkl type anlkl.
    types end of gty_st_index_anlkl.
    types gty_tt_index_anlkl type standard table of gty_st_index_anlkl with default key.

    class-data: lo_instance type ref to lcl_anlkl.
    data mt_anlkl type  gty_tt_index_anlkl.

endclass.

class lcl_anlkl implementation.


  method get_instance.

    lo_instance = cond #( when lo_instance is bound
                          then lo_instance
                          else new lcl_anlkl( ) ).

    ro_result = lo_instance.

  endmethod.

  method insert.

    insert value #( index = iv_index
                    anlkl =   |{ iv_value alpha = in }| ) into table mt_anlkl.

  endmethod.

  method validate.

    mo_faa_cfg_access->get_faac_acls0_multiple(  importing et_acls0          = data(lt_all_assetclass)
                                                 exceptions  not_found         = 1
                                                 others            = 2  ).
    if sy-subrc <> 0.
      io_mpa_output->add_app_log_message( iv_msgid   = sy-msgid
                                          iv_msgty   = sy-msgty
                                          iv_msgno   = sy-msgno
                                          iv_msgv1   = sy-msgv1
                                          iv_msgv2   = sy-msgv2
                                          iv_msgv3   = sy-msgv3
                                          iv_msgv4   = sy-msgv4 ).
    endif.

    loop at mt_anlkl reference into data(lr_anlkr).

      if line_exists( lt_all_assetclass[ asset_class = lr_anlkr->anlkl ] ).
        "do nothing
      else.

        io_mpa_output->add_app_log_message( exporting iv_row = lr_anlkr->index
                                                      iv_msgno   = 151
                                                      iv_msgty   = if_mpa_output=>gc_msg_type-error
                                                      iv_msgv1   = lr_anlkr->anlkl ).

        append value #( row = lr_anlkr->index ) to rt_invalid_row_index.

      endif.

    endloop.

  endmethod.

endclass.

class ltc_pbukrs definition deferred.
class lcl_pbukrs definition final inheriting from lcl_field friends ltc_pbukrs.

  public section.

    types gty_tt_range_pbukrs type range of pbukrs.

    class-methods get_instance returning
                                 value(ro_result) type ref to lcl_pbukrs.
    methods: validate redefinition,
      insert redefinition,
      get_range returning value(rt_bukrs_range) type gty_tt_range_pbukrs,
      get_value importing iv_index         type i
                returning value(rv_pbukrs) type pbukrs.

  private section.

    types begin of gty_st_index_pbukrs.
    types index type i .
    types pbukrs type pbukrs.
    types end of gty_st_index_pbukrs.
    types gty_tt_index_pbukrs type standard table of gty_st_index_pbukrs with default key.

    class-data: lo_instance type ref to lcl_pbukrs.

    methods : create_pbukrs_range returning value(rt_pbukrs_range) type gty_tt_range_pbukrs.

    data : mt_pbukrs       type gty_tt_index_pbukrs,
           mt_pbukrs_range type gty_tt_range_pbukrs.

endclass.

class lcl_pbukrs implementation.


  method get_instance.

    lo_instance = cond #( when lo_instance is bound
                          then lo_instance
                          else new lcl_pbukrs( ) ).

    ro_result = lo_instance.

  endmethod.

  method insert.

    data(lv_value) = cond #( when iv_value is initial
                             then lcl_bukrs=>get_instance( )->get_value( iv_index = iv_index )
                             else iv_value ).

    insert value #( index  = iv_index
                    pbukrs = |{ lv_value alpha = in }| ) into table mt_pbukrs.

  endmethod.

  method validate.

    mo_faa_cfg_access->get_faa_cfg_cmp_multiple(
      exporting
        it_range_comp_code = me->get_range( )
      importing
        et_faa_cfg_cmp     = data(et_faa_cfg_cmp)
      exceptions
        not_found          = 1
        others             = 2 ).

    if sy-subrc <> 0.
      io_mpa_output->add_app_log_message( iv_msgid   = sy-msgid
                                          iv_msgty   = sy-msgty
                                          iv_msgno   = sy-msgno
                                          iv_msgv1   = sy-msgv1
                                          iv_msgv2   = sy-msgv2
                                          iv_msgv3   = sy-msgv3
                                          iv_msgv4   = sy-msgv4 ).

    else.

      loop at mt_pbukrs reference into data(lr_pbukrs).

        if line_exists( et_faa_cfg_cmp[ comp_code = lr_pbukrs->pbukrs ] ).
          "do nothing
        else.

          io_mpa_output->add_app_log_message(   exporting iv_row = lr_pbukrs->index
                                                          iv_msgno   = 150
                                                          iv_msgty   = if_mpa_output=>gc_msg_type-error
                                                          iv_msgv1   = lr_pbukrs->pbukrs ).

          append value #( row = lr_pbukrs->index ) to rt_invalid_row_index.
        endif.

      endloop.

    endif.
  endmethod.

  method get_range.

    rt_bukrs_range = cond #( when mt_pbukrs_range is not initial
                             then mt_pbukrs_range
                             else create_pbukrs_range( ) ).

  endmethod.

  method create_pbukrs_range.

    loop at mt_pbukrs reference into data(lr_pbukrs).
      append value #( sign = cl_mpa_asset_validate=>gc_sign_include
                      option = cl_mpa_asset_validate=>gc_option_equal
                      low = lr_pbukrs->pbukrs ) to rt_pbukrs_range .
    endloop.

  endmethod.

  method get_value.

    rv_pbukrs = cond #( when line_exists( mt_pbukrs[ index = iv_index ] )
                       then mt_pbukrs[ index = iv_index ]-pbukrs ) .

  endmethod.

endclass.

class lcl_fins_ledger definition final inheriting from lcl_field .

  public section.
    class-methods get_instance returning
                                 value(ro_result) type ref to lcl_fins_ledger .
    methods: validate redefinition,
      insert redefinition.

  private section.

    types begin of gty_st_index_fins_ledger.
    types index type i .
    types fins_ledger type fins_ledger.
    types bukrs type bukrs.
    types end of gty_st_index_fins_ledger.
    types gty_tt_index_fins_ledger type standard table of gty_st_index_fins_ledger with default key.

    class-data: lo_instance type ref to lcl_fins_ledger.
    data mt_fins_ledger   type gty_tt_index_fins_ledger.

endclass.

class lcl_fins_ledger implementation.


  method get_instance.

    lo_instance = cond #( when lo_instance is bound
                          then lo_instance
                          else new lcl_fins_ledger( ) ).

    ro_result = lo_instance.

  endmethod.

  method insert.

    try.
        insert value #( index = iv_index
                        fins_ledger =   |{ iv_value alpha = in }|
                        bukrs = lcl_bukrs=>get_instance( )->get_value( iv_index ) ) into table mt_fins_ledger.
      catch cx_sy_itab_line_not_found.
        io_mpa_output->get_app_log_msg_logger( )->add_message( exporting iv_msgno   = 152
                                                                         iv_msgty   = if_mpa_output=>gc_msg_type-error ).
    endtry.

  endmethod.

  method validate.

    mo_faa_cfg_access->get_faa_cfg_cmp_ld_multiple(  exporting it_range_comp_code    =  lcl_bukrs=>get_instance( )->get_range( )
                                                     importing et_faa_cfg_cmp_ledger = data(lt_all_comp_code_ledger)
                                                     exceptions not_found             = 1
                                                                others                = 2 ).
    if sy-subrc <> 0.
      io_mpa_output->add_app_log_message( iv_msgid   = sy-msgid
                                          iv_msgty   = sy-msgty
                                          iv_msgno   = sy-msgno
                                          iv_msgv1   = sy-msgv1
                                          iv_msgv2   = sy-msgv2
                                          iv_msgv3   = sy-msgv3
                                          iv_msgv4   = sy-msgv4 ).
    endif.

    loop at  mt_fins_ledger  reference into data(lr_fins_ledger).

      if line_exists( lt_all_comp_code_ledger[ ledger  = lr_fins_ledger->fins_ledger
                                               comp_code  = lr_fins_ledger->bukrs ] ).
        "do nothing
      else.

        io_mpa_output->add_app_log_message(   exporting iv_row = lr_fins_ledger->index
                                                        iv_msgno   = 153
                                                        iv_msgty   = if_mpa_output=>gc_msg_type-error
                                                        iv_msgv1   = lr_fins_ledger->fins_ledger
                                                        iv_msgv2   =  lr_fins_ledger->bukrs ).

        append value #( row = lr_fins_ledger->index ) to rt_invalid_row_index.

      endif.

    endloop.

  endmethod.

endclass.

class lcl_afaber definition final inheriting from lcl_field.

  public section.
    class-methods get_instance returning value(ro_result) type ref to lcl_afaber.
    methods: validate redefinition,
      insert redefinition.

  private section.

    types begin of gty_st_index_afaber.
    types index type i .
    types afaber type afaber.
    types bukrs type bukrs.
    types end of gty_st_index_afaber.
    types gty_tt_index_afaber type standard table of gty_st_index_afaber with default key.

    class-data: lo_instance type ref to lcl_afaber.
    data mt_afaber type gty_tt_index_afaber.

endclass.

class lcl_afaber implementation.


  method get_instance.

    lo_instance = cond #( when lo_instance is bound
                          then lo_instance
                          else new lcl_afaber( ) ).

    ro_result = lo_instance.

  endmethod.

  method insert.

    try.
        insert value #( index = iv_index
                        afaber =   |{ iv_value alpha = in }|
                        bukrs = lcl_bukrs=>get_instance( )->get_value( iv_index ) ) into table mt_afaber.
      catch cx_sy_itab_line_not_found.
        io_mpa_output->get_app_log_msg_logger( )->add_message( exporting iv_msgno   = 152
                                                                         iv_msgty   = if_mpa_output=>gc_msg_type-error ).
    endtry.

  endmethod.

  method validate.

    mo_faa_cfg_access->get_faa_cfg_depr_area_multiple( exporting  it_range_comp_code     = lcl_bukrs=>get_instance( )->get_range( )
                                                       importing et_cfg_depr_area_s4    = data(lt_all_comp_code_dep_area)
                                                       exceptions not_found              = 1
                                                                  error_in_configuration = 2
                                                                  others                 = 3 ).

    if sy-subrc <> 0.
      io_mpa_output->add_app_log_message( iv_msgid   = sy-msgid
                                          iv_msgty   = sy-msgty
                                          iv_msgno   = sy-msgno
                                          iv_msgv1   = sy-msgv1
                                          iv_msgv2   = sy-msgv2
                                          iv_msgv3   = sy-msgv3
                                          iv_msgv4   = sy-msgv4 ).
    endif.

    loop at  mt_afaber  reference into data(lr_afaber).

      if line_exists( lt_all_comp_code_dep_area[  key comp_code_depr_area
                                                  depr_area  = lr_afaber->afaber
                                                  comp_code  = lr_afaber->bukrs ] ).
        "do nothing
      else.

        io_mpa_output->add_app_log_message( exporting iv_row = lr_afaber->index
                                                      iv_msgno   = 154
                                                      iv_msgty   = if_mpa_output=>gc_msg_type-error
                                                      iv_msgv1   = lr_afaber->afaber
                                                      iv_msgv2   = lr_afaber->bukrs ).

        append value #( row = lr_afaber->index ) to rt_invalid_row_index.
      endif.

    endloop.

  endmethod.

endclass.

class ltc_anln1 definition deferred.
class lcl_anln1 definition final inheriting from lcl_field friends ltc_anln1.

  public section.
    class-methods get_instance returning
                                 value(ro_result) type ref to lcl_anln1.
    methods: validate redefinition,
      insert redefinition.
    methods get_value
      importing
        iv_index        type i
      returning
        value(r_result) type anln1.

  private section.

    class-data: lo_instance type ref to lcl_anln1.

    types begin of lty_st_index_anln1.
    types index type i .
    types anln1 type anln1.
    types bukrs type bukrs.
    types end of lty_st_index_anln1.
    types lty_tt_index_anln1 type standard table of lty_st_index_anln1 with default key.

    data mt_anln1         type lty_tt_index_anln1.

endclass.

class lcl_anln1 implementation.


  method get_instance.

    lo_instance = cond #( when lo_instance is bound
                          then lo_instance
                          else new lcl_anln1( ) ).

    ro_result = lo_instance.

  endmethod.

  method insert.

    try.
        insert value #( index = iv_index
                        anln1 =  |{ iv_value alpha = in }|
                        bukrs = lcl_bukrs=>get_instance( )->get_value( iv_index ) ) into table mt_anln1.
      catch cx_sy_itab_line_not_found.
        io_mpa_output->get_app_log_msg_logger( )->add_message( exporting iv_msgno   = 152
                                                                         iv_msgty   = if_mpa_output=>gc_msg_type-error ).
    endtry.

  endmethod.

  method validate.

    loop at mt_anln1 reference into data(lr_anln1) where bukrs is not initial.

      if mo_faa_md_data_access->check_asset_existed( exporting iv_asset_no    = lr_anln1->anln1
                                                                                iv_comp_code   = lr_anln1->bukrs  ) = abap_false .

        io_mpa_output->add_app_log_message( exporting iv_row = lr_anln1->index
                                                      iv_msgno   = 155
                                                      iv_msgty   = if_mpa_output=>gc_msg_type-error
                                                      iv_msgv1   = lr_anln1->anln1
                                                      iv_msgv2   = lr_anln1->bukrs ).
        append value #( row = lr_anln1->index ) to rt_invalid_row_index.
      endif.

    endloop.

  endmethod.


  method get_value.

    r_result = cond #( when line_exists( mt_anln1[ index = iv_index ] )
                       then mt_anln1[ index = iv_index ]-anln1 ) .

  endmethod.

endclass.

class ltc_panl1 definition deferred.
class lcl_panl1 definition final inheriting from lcl_field friends ltc_panl1.

  public section.
    class-methods get_instance returning
                                 value(ro_result) type ref to lcl_panl1.
    methods: validate redefinition,
      insert redefinition.
    methods get_value
      importing
        iv_index        type i
      returning
        value(r_result) type panl1.

  protected section.

  private section.

    types begin of gty_st_index_panl1.
    types index type i .
    types panl1 type panl1.
    types pbukrs type pbukrs.
    types end of gty_st_index_panl1.
    types gty_tt_index_panl1 type standard table of gty_st_index_panl1 with default key.

    class-data: lo_instance type ref to lcl_panl1.
    data mt_panl1 type gty_tt_index_panl1.

endclass.

class lcl_panl1 implementation.


  method get_instance.

    lo_instance = cond #( when lo_instance is bound
                          then lo_instance
                          else new lcl_panl1( ) ).

    ro_result = lo_instance.

  endmethod.

  method insert.

    try.
        insert value #( index  = iv_index
                        panl1  =  |{ iv_value alpha = in }|
                        pbukrs = cond #( when lcl_pbukrs=>get_instance( )->get_value( iv_index ) is initial
                                         then lcl_bukrs=>get_instance( )->get_value( iv_index )
                                         else lcl_pbukrs=>get_instance( )->get_value( iv_index ) ) ) into table mt_panl1.
      catch cx_sy_itab_line_not_found.
        io_mpa_output->get_app_log_msg_logger( )->add_message( exporting iv_msgno   = 152
                                                                         iv_msgty   = if_mpa_output=>gc_msg_type-error ).
    endtry.

  endmethod.

  method validate.

    loop at mt_panl1 reference into data(lr_panl1).

      if mo_faa_md_data_access->check_asset_existed( exporting iv_asset_no    = lr_panl1->panl1
                                                                                iv_comp_code   = lr_panl1->pbukrs ) = abap_false .

        io_mpa_output->add_app_log_message(   exporting iv_row = lr_panl1->index
                                                        iv_msgno   = 156
                                                        iv_msgty   = if_mpa_output=>gc_msg_type-error
                                                        iv_msgv1   = lr_panl1->panl1
                                                        iv_msgv2   = lr_panl1->pbukrs ).
        append value #( row = lr_panl1->index ) to rt_invalid_row_index.
      endif.

    endloop.

  endmethod.

  method get_value.

    r_result = cond #( when line_exists( mt_panl1[ index = iv_index ] )
                       then mt_panl1[ index = iv_index ]-panl1 ) .

  endmethod.

endclass.

class ltc_anln2 definition deferred.
class lcl_anln2 definition final inheriting from lcl_field friends ltc_anln2.

  public section.
    class-methods get_instance returning
                                 value(ro_result) type ref to lcl_anln2.
    methods: validate redefinition,
      insert redefinition.

  protected section.

  private section.
    types begin of lty_st_index_anln2.
    types index type i .
    types anln2 type anln2.
    types anln1 type anln1.
    types bukrs type bukrs.
    types end of lty_st_index_anln2.
    types lty_tt_index_anln2 type standard table of lty_st_index_anln2 with default key.

    class-data: lo_instance type ref to lcl_anln2.
    data mt_anln2 type lty_tt_index_anln2.

endclass.

class lcl_anln2 implementation.


  method get_instance.

    lo_instance = cond #( when lo_instance is bound
                          then lo_instance
                          else new lcl_anln2( ) ).

    ro_result = lo_instance.

  endmethod.

  method insert.

    if iv_value  ge 1.
      try.
          insert value #( index = iv_index
                          anln2 =   |{ iv_value alpha = in }|
                          anln1 = lcl_anln1=>get_instance( )->get_value( iv_index )
                          bukrs = lcl_bukrs=>get_instance( )->get_value( iv_index ) ) into table mt_anln2.
        catch cx_sy_itab_line_not_found.
          io_mpa_output->get_app_log_msg_logger( )->add_message( exporting iv_msgno   = 158
                                                                           iv_msgty   = if_mpa_output=>gc_msg_type-error ).
      endtry.
    endif.

  endmethod.

  method validate.

    loop at mt_anln2 reference into data(lr_anln2).

      if mo_faa_md_data_access->check_asset_existed( exporting iv_asset_no    = lr_anln2->anln1
                                                                                iv_comp_code   = lr_anln2->bukrs
                                                                                iv_asset_subno =  lr_anln2->anln2 ) = abap_false .

        io_mpa_output->add_app_log_message(   exporting iv_row = lr_anln2->index
                                                        iv_msgno   = 157
                                                        iv_msgty   = if_mpa_output=>gc_msg_type-error
                                                        iv_msgv1   = lr_anln2->anln1
                                                        iv_msgv2   = lr_anln2->anln2
                                                        iv_msgv3   = lr_anln2->bukrs ).
        append value #( row = lr_anln2->index ) to rt_invalid_row_index.
      endif.

    endloop.

  endmethod.



endclass.

class ltc_panl2 definition deferred.
class lcl_panl2 definition final inheriting from lcl_field friends ltc_panl2.

  public section.
    class-methods get_instance returning
                                 value(ro_result) type ref to lcl_panl2.
    methods: validate redefinition,
      insert redefinition.

  protected section.

  private section.

    types begin of gty_st_index_anln2.
    types index type i .
    types panl2 type panl2.
    types panl1 type panl1.
    types pbukrs type pbukrs.
    types end of gty_st_index_anln2.
    types gty_tt_index_anln2 type standard table of gty_st_index_anln2 with default key.

    class-data: lo_instance type ref to lcl_panl2.

    data mt_panl2 type gty_tt_index_anln2.

endclass.

class lcl_panl2 implementation.


  method get_instance.

    lo_instance = cond #( when lo_instance is bound
                          then lo_instance
                          else new lcl_panl2( ) ).

    ro_result = lo_instance.

  endmethod.

  method insert.

    if iv_value ge 1.
      try.
          insert value #( index = iv_index
                          panl2 =   |{ iv_value alpha = in }|
                          panl1 = lcl_panl1=>get_instance( )->get_value( iv_index )
                          pbukrs = cond #( when lcl_pbukrs=>get_instance( )->get_value( iv_index ) is initial
                                           then lcl_bukrs=>get_instance( )->get_value( iv_index )
                                           else lcl_pbukrs=>get_instance( )->get_value( iv_index ) ) ) into table mt_panl2.
        catch cx_sy_itab_line_not_found.
          io_mpa_output->get_app_log_msg_logger( )->add_message( exporting iv_msgno = 158
                                                                           iv_msgty   = if_mpa_output=>gc_msg_type-error ).
      endtry.
    endif.

  endmethod.

  method validate.

    loop at mt_panl2 reference into data(lr_panl2).

      if mo_faa_md_data_access->check_asset_existed( exporting iv_asset_no    = lr_panl2->panl1
                                                                                iv_comp_code   = lr_panl2->pbukrs
                                                                                iv_asset_subno =  lr_panl2->panl2 ) = abap_false .
        io_mpa_output->add_app_log_message(   exporting iv_row = lr_panl2->index
                                                        iv_msgno   = 161
                                                        iv_msgty   = if_mpa_output=>gc_msg_type-error
                                                        iv_msgv1   = lr_panl2->panl1
                                                        iv_msgv2   = lr_panl2->panl2
                                                        iv_msgv3   = lr_panl2->pbukrs ).
        append value #( row = lr_panl2->index ) to rt_invalid_row_index.

      endif.

    endloop.

  endmethod.

endclass.

class ltc_kostl definition deferred.
class lcl_kostl definition final inheriting from lcl_field friends ltc_kostl.

  public section.
    class-methods get_instance returning
                                 value(ro_result) type ref to lcl_kostl.
    methods: validate redefinition,
      insert redefinition.

  protected section.

  private section.

    types begin of gty_st_index_kostl.
    types index type i .
    types kostl type kostl.
    types bukrs type bukrs.
    types end of gty_st_index_kostl.
    types gty_tt_index_kostl type standard table of gty_st_index_kostl with default key.

    class-data: lo_instance type ref to lcl_kostl.
    data mt_kostl type gty_tt_index_kostl.

endclass.

class lcl_kostl implementation.


  method get_instance.

    lo_instance = cond #( when lo_instance is bound
                          then lo_instance
                          else new lcl_kostl( ) ).

    ro_result = lo_instance.

  endmethod.

  method insert.

    "collect cost center
    try.
        insert value #( index = iv_index
                        kostl =   |{ iv_value alpha = in }|
                        bukrs = lcl_bukrs=>get_instance( )->get_value( iv_index ) ) into table mt_kostl.
      catch cx_sy_itab_line_not_found.
        io_mpa_output->get_app_log_msg_logger( )->add_message( exporting iv_msgno = 152
                                                     iv_msgty   = if_mpa_output=>gc_msg_type-error ).
    endtry.

  endmethod.

  method validate.

    data : lt_range_kostl type range of kostl,
           lt_range_bukrs type range of bukrs.
    "get meins range table
    loop at mt_kostl reference into data(lr_kostl).
      append value #( sign = cl_mpa_asset_validate=>gc_sign_include
                      option = cl_mpa_asset_validate=>gc_option_equal
                      low = lr_kostl->kostl ) to lt_range_kostl.
    endloop.

    lt_range_bukrs = lcl_bukrs=>get_instance( )->get_range( ).

    select kostl, bukrs into table @data(lt_kostl_bukrs)
                        from csks
                       where kostl in @lt_range_kostl
                         and bukrs in @lt_range_bukrs . "#EC CI_GENBUFF

    loop at mt_kostl reference into lr_kostl .

      if line_exists( lt_kostl_bukrs[  kostl = lr_kostl->kostl
                                       bukrs = lr_kostl->bukrs ] ).
        "do nothing
      else.
        io_mpa_output->add_app_log_message(   exporting iv_row = lr_kostl->index
                                                        iv_msgno   = 159
                                                        iv_msgty   = if_mpa_output=>gc_msg_type-error
                                                        iv_msgv1   = lr_kostl->kostl
                                                        iv_msgv2   = lr_kostl->bukrs ).
        append value #( row = lr_kostl->index ) to rt_invalid_row_index.
      endif.


    endloop.


  endmethod.

endclass.

class ltc_meins definition deferred.
class lcl_meins definition final inheriting from lcl_field friends ltc_meins.

  public section.
    class-methods get_instance returning
                                 value(ro_result) type ref to lcl_meins.
    methods: validate redefinition,
      insert redefinition.

  protected section.

  private section.

    types begin of gty_st_index_meins.
    types index type i .
    types meins type meins.
    types end of gty_st_index_meins.
    types gty_tt_index_meins type standard table of gty_st_index_meins with default key.

    class-data: lo_instance type ref to lcl_meins.

    data mt_meins type gty_tt_index_meins.

endclass.

class lcl_meins implementation.


  method get_instance.

    lo_instance = cond #( when lo_instance is bound
                          then lo_instance
                          else new lcl_meins( ) ).

    ro_result = lo_instance.

  endmethod.

  method insert.
    "collect meins
    insert value #( index = iv_index
                    meins =  iv_value   ) into table mt_meins.
  endmethod.

  method validate.

    data lt_range_meins type range of meins.

    "get meins range table
    loop at mt_meins reference into data(lr_meins).
      append value #( sign = cl_mpa_asset_validate=>gc_sign_include
                      option = cl_mpa_asset_validate=>gc_option_equal
                      low = lr_meins->meins ) to lt_range_meins.
    endloop.

    select msehi into table @data(lt_msehi)
                 from t006
                 where msehi in @lt_range_meins.

    loop at mt_meins reference into lr_meins.

      if line_exists( lt_msehi[ msehi = lr_meins->meins ] ).
        "do nothing
      else.
        io_mpa_output->add_app_log_message( exporting iv_row = lr_meins->index
                                                      iv_msgno   = 160
                                                      iv_msgty   = if_mpa_output=>gc_msg_type-error
                                                      iv_msgv1   = lr_meins->meins  ).
        append value #( row = lr_meins->index ) to rt_invalid_row_index.
      endif.


    endloop.

  endmethod.

endclass.

class ltc_waers definition deferred.
class lcl_waers definition final inheriting from lcl_field friends ltc_waers.

  public section.
    class-methods get_instance returning
                                 value(ro_result) type ref to lcl_waers.
    methods: validate redefinition,
      insert redefinition.

  protected section.

  private section.

    types begin of gty_st_index_waers.
    types index type i .
    types waers type waers.
    types end of gty_st_index_waers.
    types gty_tt_index_waers type standard table of gty_st_index_waers with default key.

    class-data: lo_instance type ref to lcl_waers.
    data mt_waers type gty_tt_index_waers.
endclass.

class lcl_waers implementation.


  method get_instance.

    lo_instance = cond #( when lo_instance is bound
                          then lo_instance
                          else new lcl_waers( ) ).

    ro_result = lo_instance.

  endmethod.

  method insert.

    insert value #( index = iv_index
                    waers =  |{ iv_value alpha = in }| ) into table mt_waers.

  endmethod.

  method validate.

    data lt_range_waers type range of waers.

    "get waers range table
    loop at mt_waers reference into data(lr_waers).
      append value #( sign = cl_mpa_asset_validate=>gc_sign_include
                      option = cl_mpa_asset_validate=>gc_option_equal
                      low = lr_waers->waers ) to lt_range_waers.
    endloop.

    select waers  into table @data(lt_waers)
                 from tcurc
                 where waers in @lt_range_waers.

    loop at mt_waers reference into lr_waers.

      if line_exists( lt_waers[ waers  = lr_waers->waers ] ).
        "do nothing
      else.

        io_mpa_output->add_app_log_message( exporting iv_row = lr_waers->index
                                                      iv_msgno   = 162
                                                      iv_msgty   = if_mpa_output=>gc_msg_type-error
                                                      iv_msgv1   = lr_waers->waers ).
        append value #( row = lr_waers->index ) to rt_invalid_row_index.

      endif.


    endloop.

  endmethod.

endclass.

class lcl_monat definition final inheriting from lcl_field.

  public section.
    class-methods get_instance returning
                                 value(ro_result) type ref to lcl_monat.
    methods: validate redefinition,
      insert redefinition.

  protected section.

  private section.

    types begin of gty_st_index_monat.
    types index type i .
    types monat type monat.
    types end of gty_st_index_monat.
    types gty_tt_index_monat type standard table of gty_st_index_monat with default key.

    class-data: lo_instance type ref to lcl_monat.

    data mt_monat type gty_tt_index_monat.

endclass.

class lcl_monat implementation.


  method get_instance.

    lo_instance = cond #( when lo_instance is bound
                          then lo_instance
                          else new lcl_monat( ) ).

    ro_result = lo_instance.

  endmethod.

  method insert.

    insert value #( index = iv_index
                    monat = iv_value ) into table mt_monat.



  endmethod.

  method validate.

    loop at mt_monat reference into data(lr_monat) where monat > 16 or monat < 1.

      io_mpa_output->add_app_log_message( exporting iv_row = lr_monat->index
                                                    iv_msgno = 163
                                                    iv_msgty = if_mpa_output=>gc_msg_type-error ).
      append value #( row = lr_monat->index ) to rt_invalid_row_index.

    endloop.

  endmethod.

endclass.

class lcl_adatu definition final inheriting from lcl_field.

  public section.
    class-methods get_instance returning
                                 value(ro_result) type ref to lcl_adatu.
    methods: validate redefinition,
      insert redefinition.

  protected section.

  private section.

    types begin of gty_st_index_date.
    types index type i .
    types date type dats.
    types end of gty_st_index_date.
    types gty_tt_index_date type standard table of gty_st_index_date with default key.

    class-data: lo_instance type ref to lcl_adatu.
    data mt_date type gty_tt_index_date.

endclass.

class lcl_adatu implementation.


  method get_instance.

    lo_instance = cond #( when lo_instance is bound
                          then lo_instance
                          else new lcl_adatu( ) ).

    ro_result = lo_instance.

  endmethod.

  method insert.

    "collect date
    insert value #( index = iv_index
                    date = iv_value ) into table mt_date.

  endmethod.

  method validate.

    "validate date
    loop at mt_date reference into data(lr_date).

      call function 'DATE_CHECK_PLAUSIBILITY'
        exporting
          date                      = lr_date->date
        exceptions
          plausibility_check_failed = 1
          others                    = 2.
      if sy-subrc <> 0.
        io_mpa_output->add_app_log_message( exporting iv_row = lr_date->index
                                                      iv_msgno = 164
                                                      iv_msgty   = if_mpa_output=>gc_msg_type-error
                                                      iv_msgv1 = lr_date->date ).
        append value #( row = lr_date->index ) to rt_invalid_row_index.
      endif..
    endloop.

  endmethod.

endclass.

class ltc_werks_d definition deferred.
class lcl_werks_d definition final inheriting from lcl_field friends ltc_werks_d.

  public section.
    class-methods get_instance returning
                                 value(ro_result) type ref to lcl_werks_d.
    methods: validate redefinition,
      insert redefinition.

  protected section.

  private section.

    types begin of gty_st_index_plant.
    types index type i .
    types plant type werks_d.
    types end of gty_st_index_plant.
    types gty_tt_index_plant type standard table of gty_st_index_plant with default key.

    class-data: lo_instance type ref to lcl_werks_d.
    data mt_plant type gty_tt_index_plant.


endclass.

class lcl_werks_d implementation.


  method get_instance.

    lo_instance = cond #( when lo_instance is bound
                          then lo_instance
                          else new lcl_werks_d( ) ).

    ro_result = lo_instance.

  endmethod.

  method insert.

    insert value #( index = iv_index
                    plant =  |{ iv_value alpha = in }| ) into table mt_plant.

  endmethod.

  method validate.

    loop at mt_plant reference into data(lr_plant).
      if  mo_faa_md_data_access->check_plant_existed( iv_plant = lr_plant->plant ) = abap_false.

        io_mpa_output->add_app_log_message( exporting iv_row = lr_plant->index
                                                      iv_msgno = 165
                                                      iv_msgty   = if_mpa_output=>gc_msg_type-error
                                                      iv_msgv1 = lr_plant->plant ).
        append value #( row = lr_plant->index ) to rt_invalid_row_index.

      endif.
    endloop.

  endmethod.

endclass.

class ltc_rassc definition deferred.
class lcl_rassc definition final inheriting from lcl_field friends ltc_rassc.

  public section.
    class-methods get_instance returning
                                 value(ro_result) type ref to lcl_rassc.
    methods: validate redefinition,
      insert redefinition.

  protected section.

  private section.

    types begin of gty_st_index_rassc.
    types index type i .
    types rassc type rassc.
    types end of gty_st_index_rassc.
    types gty_tt_index_rassc type standard table of gty_st_index_rassc with default key.

    class-data: lo_instance type ref to lcl_rassc.

    data mt_rassc type gty_tt_index_rassc.

endclass.

class lcl_rassc implementation.


  method get_instance.

    lo_instance = cond #( when lo_instance is bound
                          then lo_instance
                          else new lcl_rassc( ) ).

    ro_result = lo_instance.

  endmethod.

  method insert.

    insert value #( index = iv_index
                    rassc =  |{ iv_value alpha = in }| ) into table mt_rassc.

  endmethod.

  method validate.

    loop at mt_rassc reference into data(lr_rassc).
      try.
          if  mo_faa_md_data_access->check_trading_partner( iv_assettradeid = lr_rassc->rassc ) = abap_false.

            io_mpa_output->add_app_log_message( exporting iv_row = lr_rassc->index
                                                          iv_msgno = 166
                                                          iv_msgty   = if_mpa_output=>gc_msg_type-error
                                                          iv_msgv1 = lr_rassc->rassc ).
            append value #( row = lr_rassc->index ) to rt_invalid_row_index.

          endif.
        catch cm_faa_md.
          "handle exception
      endtry.
*                CATCH BEFORE UNWIND cm_faa_md.
    endloop.


  endmethod.

endclass.

class ltc_acc_principle definition deferred.

class lcl_acc_principle definition final inheriting from lcl_field friends ltc_acc_principle.

  public section.
    class-methods get_instance returning
                                 value(ro_result) type ref to lcl_acc_principle.
    methods: validate redefinition,
      insert redefinition.

  protected section.

  private section.

    types begin of gty_st_index_acc_principle.
    types index type i .
    types accounting_principle  type accounting_principle.
    types end of gty_st_index_acc_principle.
    types gty_tt_index_acc_principle type standard table of gty_st_index_acc_principle with default key.

    class-data: lo_instance type ref to lcl_acc_principle.
    data mt_acc_principle type  gty_tt_index_acc_principle.

endclass.

class lcl_acc_principle implementation.


  method get_instance.

    lo_instance = cond #( when lo_instance is bound
                          then lo_instance
                          else new lcl_acc_principle( ) ).

    ro_result = lo_instance.

  endmethod.

  method insert.

    insert value #( index = iv_index
                    accounting_principle =  |{ iv_value alpha = in }| ) into table mt_acc_principle.

  endmethod.

  method validate.

    data lt_all_acc_principle type faa_t_acctasn1a .

    mo_faa_cfg_access->get_faac_acctasn1a_multiple( importing et_acctasn1a     = lt_all_acc_principle
                                                   exceptions not_found        = 1
                                                              others           = 2 ).

    if sy-subrc <> 0.
      io_mpa_output->add_app_log_message( iv_msgid   = sy-msgid
                                          iv_msgty   = sy-msgty
                                          iv_msgno   = sy-msgno
                                          iv_msgv1   = sy-msgv1
                                          iv_msgv2   = sy-msgv2
                                          iv_msgv3   = sy-msgv3
                                          iv_msgv4   = sy-msgv4 ).
    else.

      loop at mt_acc_principle reference into data(lr_acc_principle).

        if line_exists( lt_all_acc_principle[ acc_principle = lr_acc_principle->accounting_principle
                                              is_active = abap_true ] ).
          "do nothing
        else.

*        "Check and add row number to application log
*        io_mpa_output->check_and_add_row_msg( lr_acc_principle->index ).

          io_mpa_output->add_app_log_message( exporting iv_row = lr_acc_principle->index
                                                        iv_msgno = 167
                                                        iv_msgty   = if_mpa_output=>gc_msg_type-error
                                                        iv_msgv1 = lr_acc_principle->accounting_principle ).
          append value #( row = lr_acc_principle->index ) to rt_invalid_row_index.

        endif.

      endloop.

    endif.

  endmethod.

endclass.

class lcl_am_land1 definition final inheriting from lcl_field.

  public section.
    class-methods get_instance returning
                                 value(ro_result) type ref to lcl_am_land1.
    methods: validate redefinition,
      insert redefinition.

  private section.

    types begin of gty_st_index_am_land1.
    types index type i .
    types am_land1 type am_land1.
    types end of gty_st_index_am_land1.
    types gty_tt_index_am_land1 type standard table of gty_st_index_am_land1 with default key.

    class-data: lo_instance type ref to lcl_am_land1.
    data mt_land type  gty_tt_index_am_land1.

endclass.

class lcl_am_land1 implementation.


  method get_instance.

    lo_instance = cond #( when lo_instance is bound
                          then lo_instance
                          else new lcl_am_land1( ) ).

    ro_result = lo_instance.

  endmethod.

  method insert.

    insert value #( index = iv_index
                    am_land1 =  |{ iv_value alpha = in }| ) into table mt_land.

  endmethod.

  method validate.

    loop at mt_land reference into data(lr_land).
      if  mo_faa_md_data_access->check_country_origin( iv_assetcountryoforigin = lr_land->am_land1 ) = abap_false.

        io_mpa_output->add_app_log_message( exporting iv_row   = lr_land->index
                                                      iv_msgno = 173
                                                      iv_msgty = if_mpa_output=>gc_msg_type-error
                                                      iv_msgv1 = lr_land->am_land1 ).
        append value #( row = lr_land->index ) to rt_invalid_row_index.

      endif.
    endloop.

  endmethod.

endclass.

class lcl_field implementation.

  method get_field_instance.

    ro_result = switch #( iv_data_type
                          when cl_mpa_asset_validate=>gc_field_type-bukrs         then lcl_bukrs=>get_instance( )
                          when cl_mpa_asset_validate=>gc_field_type-pbukrs        then lcl_pbukrs=>get_instance( )
                          when cl_mpa_asset_validate=>gc_field_type-anlkl         then lcl_anlkl=>get_instance( )
                          when cl_mpa_asset_validate=>gc_field_type-fins_ledger   then lcl_fins_ledger=>get_instance( )
                          when cl_mpa_asset_validate=>gc_field_type-afaber        then lcl_afaber=>get_instance( )
                          when cl_mpa_asset_validate=>gc_field_type-anln1         then lcl_anln1=>get_instance( )
                          when cl_mpa_asset_validate=>gc_field_type-panl1         then lcl_panl1=>get_instance( )
                          when cl_mpa_asset_validate=>gc_field_type-anln2         then lcl_anln2=>get_instance( )
                          when cl_mpa_asset_validate=>gc_field_type-panl2         then lcl_panl2=>get_instance( )
                          when cl_mpa_asset_validate=>gc_field_type-kostl         then lcl_kostl=>get_instance( )
                          when cl_mpa_asset_validate=>gc_field_type-meins         then lcl_meins=>get_instance( )
                          when cl_mpa_asset_validate=>gc_field_type-waers         then lcl_waers=>get_instance( )
                          when cl_mpa_asset_validate=>gc_field_type-monat         then lcl_monat=>get_instance( )
                          when cl_mpa_asset_validate=>gc_field_type-adatu         then lcl_adatu=>get_instance( )
                          when cl_mpa_asset_validate=>gc_field_type-am_land1      then lcl_am_land1=>get_instance( )
                          when cl_mpa_asset_validate=>gc_field_type-werks_d       then lcl_werks_d=>get_instance( )
                          when cl_mpa_asset_validate=>gc_field_type-rassc         then lcl_rassc=>get_instance( )
                          when cl_mpa_asset_validate=>gc_field_type-acc_principle then lcl_acc_principle=>get_instance( )
                          when cl_mpa_asset_validate=>gc_field_type-trava         then lcl_trava=>get_instance( )
                          when cl_mpa_asset_validate=>gc_field_type-blart         then lcl_blart=>get_instance( )
                          when cl_mpa_asset_validate=>gc_field_type-recid         then lcl_recid=>get_instance( ) ).

    collect ro_result into gt_fields.

  endmethod.


  method validate_fields.

*    DATA(lo_app_msg_logger) = io_mpa_output->get_app_log_msg_logger( ).

    loop at gt_fields reference into data(lr_field).

      append lines of lr_field->*->validate( io_mpa_output ) to rt_invalid_row_number.

    endloop.

  endmethod.

  method constructor.

    mo_faa_md_data_access = cond #( when go_faa_md_data_access_fake is not initial
                                    then go_faa_md_data_access_fake
                                    else cl_faa_md_data_access=>get_instance( ) ).
    mo_faa_cfg_access = cond #( when go_faa_cfg_access_fake is not initial
                                then go_faa_cfg_access_fake
                                else cl_faa_cfg_access=>get_instance( ) ).

  endmethod.

endclass.
