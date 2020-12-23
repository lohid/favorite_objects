*"* use this source file for your ABAP unit test classes

class ltc_mpa_asset_validate definition deferred.

class zcl_asset_validation definition local friends ltc_mpa_asset_validate
                                                     ltc_mpa_asset_validate_dummy
                                                     ltc_pbukrs
                                                     ltc_bukrs
                                                     ltc_acc_principle.

"! Helper class for test classes
class lcl_helper definition final
for testing
create private.

  public section.

    constants : gc_company_cmp1         type bukrs value 'CMP1',
                gc_company_cmp2         type bukrs value 'CMP2',
                gc_year_2012            type gjahr value '2012',
                gc_asset_number_1000001 type bf_anln1 value '1000001',
                gc_asset_number_1000002 type bf_anln1 value '1000002',
                gc_asset_number_1000003 type bf_anln1 value '1000003',
                gc_asset_class_1100     type bf_anlkl  value '1100',
                gc_asset_class_1101     type bf_anlkl  value '1101',
                gc_asset_class_1102     type bf_anlkl  value '1102',
                gc_asset_desc_1         type txa50_anlt  value 'Asset description 1' ##NO_TEXT,
                gc_asset_sernr_101      type am_sernr value '101',
                gc_asset_invnr_3001     type invnr_anla value '3001',
                gc_unit_acr             type meins value 'ACR',
                gc_date_01_01_19        type bstdt value '20190101',
                gc_date_02_02_19        type bstdt value '20190202',
                gc_date_03_03_19        type bstdt value '20190303',
                gc_kostl_kost1          type kostl value 'KOST1',
                gc_wbs_0012             type ps_s4_pspnr  value '0012',
                gc_profitcenter_prctr1  type prctr value 'PRCTR1',
                gc_segment_segment1     type fb_segment value 'SEGMENT1',
                gc_plantpnt1            type werks_d value 'PNT1',
                gc_location_loc1        type stort value 'LOC1',
                gc_room_raumnr1         type bf_raumnr  value 'RAUMNR1',
                gc_txjcd_txjcd1         type txjcd value 'TXJCD1',
                gc_vendor_vnd1          type am_lifnr value 'VND1',
                gc_manufacturer_man1    type herst value 'MAN1',
                gc_country_us           type bf_am_land1 value 'US',
                gc_assettype_type1      type typbz_anla value 'TYPE1',
                gc_percentage_25        type antei  value '25',
                gc_tradeid_ptn1         type rassc  value 'PTN1',
                gc_ledger_0l            type fins_ledger value '0L',
                gc_ledger_2l            type fins_ledger value '2L',
                gc_ledger_3l            type fins_ledger value '3L',
                gc_depr_area_01         type afabe_d value '01',
                gc_depr_area_15         type afabe_d value '15',
                gc_depr_area_32         type afabe_d value '32',
                gc_depr_area_34         type afabe_d value '34',
                gc_depr_area_81         type afabe_d value '81',
                gc_dep_key_lins         type afasl value 'LINS',
                gc_dep_key_leax         type afasl value 'LEAX',
                gc_dep_key_sul1         type afasl value 'SUL1',
                gc_num_3                type char3 value '003',
                gc_num_10               type char3 value '010',
                gc_num_5                type char3 value '005',
                gc_num_20               type char3 value '020',
                gc_num_50               type char3 value '050',
                gc_curr_eur             type faa_md_org_acq_curr value 'EUR',
                gc_amount_100           type fins_vhcur12 value '100',
                gc_recid_01             type jv_recind value '01',
                gc_blart_01             type blart value '01',
                gc_trava_0001           type transvar value '0001',
                gc_acc_principle_ifrs   type accounting_principle value 'IFRS'.

endclass.

class ltd_faa_cfg_access definition final for testing.

  public section.
    interfaces if_faa_cfg_access partially implemented.

endclass.

class ltd_faa_cfg_access implementation.

  method if_faa_cfg_access_s4~get_faa_cfg_cmp_multiple.

    if lcl_helper=>gc_company_cmp1 not in it_range_comp_code.

      message id sy-msgid type sy-msgty number sy-msgno
             with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
          raising not_found.

    endif.

  endmethod.

  method if_faa_cfg_access_s4~get_faac_acctasn1a_multiple.


    message id sy-msgid type sy-msgty number sy-msgno
           with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
        raising not_found.


  endmethod.


endclass.

class ltc_mpa_asset_validate_dummy definition
 for testing
  risk level harmless
  duration short.

  private section.

    class-data: go_osql_environment type ref to if_osql_test_environment .

    data :

      mo_mpa_validate type ref to zcl_asset_validation,
      mo_mpa_output   type ref to if_mpa_output.

    class-methods :

      class_setup,
      class_teardown.

    methods :
      setup ,
      run_validation_create for testing,
      run_validation_transfer for testing raising cx_static_check.

endclass.

class ltc_mpa_asset_validate_dummy implementation.

  method class_setup.

    cl_mpa_asset_process_injector=>inject_mpa_output_instance( ).


    lcl_field=>go_faa_cfg_access_fake = cast  if_faa_cfg_access( cl_abap_testdouble=>create( 'IF_FAA_CFG_ACCESS' ) ) .
    lcl_field=>go_faa_md_data_access_fake = cast  if_faa_md_data_access( cl_abap_testdouble=>create( 'IF_FAA_MD_DATA_ACCESS ' ) ) .

    "register the tables that will be mocked by the test methods
    go_osql_environment = cl_osql_test_environment=>create( value #(
                                                                     "check_posting
                                                                     ( 'CSKS' )
                                                                     ( 'T006' )
                                                                     ( 'TCURC' )
                                                                     ( 'T8JJ' )
                                                                     ( 'T003' ) ) ).

    data: lt_csks type table of csks.   "Cost Center Master Record

    "Cost Center Master Record
    lt_csks = value #(
                       (
                         mandt = sy-mandt
                         kokrs = 'C001'
                         kostl = 'ZBEERG_230'
                         datbi = '99991231'
                         datab = '20191119'
                         bukrs = 'F111'
                         kosar = '9'
                         verak = 'test'
                         waers = 'USD'
                         prctr = 'ZY027'
                         ersda = '20191119'
                         usnam = 'BEERG'
                         bkzer = abap_true
                         bkzob = abap_true
                         pkzer = abap_true
                         khinr = 'H1000'
                         kompl = abap_true
                         objnr = 'KSC001ZBEERG_230'
                         func_area = 'YB35'
                       )
                       (
                         mandt = sy-mandt
                         kokrs = 'COG3'
                         kostl = 'SFUT001904'
                         datbi = '99991231'
                         datab = '20150101'
                         bukrs = 'COG3'
                         kosar = 'G'
                         verak = 'SAP'
                         waers = 'EUR'
                         prctr = 'CPC_05'
                         ersda = '20191120'
                         usnam = 'ULLRICHB'
                         khinr = '0000000001'
                         kompl = abap_true
                         objnr = 'KSCOG3SFUT001904'
                       )
                       (
                         mandt = sy-mandt
                         kokrs = 'ZM01'
                         kostl = '0000000060'
                         datbi = '99991231'
                         datab = '20190101'
                         bukrs = 'TT02'
                         gsber = '0001'
                         kosar = '9'
                         verak = 'testing'
                         prctr = 'PC01'
                         khinr = '0001~'
                       )
                       (
                         mandt = sy-mandt
                         kokrs = 'COG3'
                         kostl = 'SFUT002080'
                         datbi = '99991231'
                         datab = '20150101'
                         bukrs = 'COG3'
                         kosar = 'G'
                         verak = 'SAP'
                         waers = 'EUR'
                         prctr = 'CPC_05'
                         ersda = '20200403'
                         usnam = 'ULLRICHB'
                         khinr = '0000000001'
                         kompl = abap_true
                         objnr = 'KSCOG3SFUT002080'
                       )
                     ).

    go_osql_environment->insert_test_data( lt_csks ).

    data: lt_t006 type table of t006.   "Units of Measurement

    "Units of Measurement
    lt_t006 = value #(
                       (
                         mandt = sy-mandt
                         msehi = '%'
                         kzex3 = abap_true
                         kzex6 = abap_true
                         kzkeh = abap_true
                         dimid = 'PROPOR'
                         zaehl = '1'
                         nennr = '100'
                         isocode = 'P1'
                       )
                       (
                         mandt = sy-mandt
                         msehi = '%O'
                         kzex3 = abap_true
                         kzex6 = abap_true
                         kzkeh = abap_true
                         dimid = 'PROPOR'
                         zaehl = '1'
                         nennr = '1000'
                       )
                       (
                         mandt = sy-mandt
                         msehi = '1'
                         kzex3 = abap_true
                         kzex6 = abap_true
                         dimid = 'PROPOR'
                         zaehl = '1'
                         nennr = '1'
                       )
                       (
                         mandt = sy-mandt
                         msehi = '10'
                         kzex3 = abap_true
                         kzex6 = abap_true
                         kzkeh = abap_true
                         dimid = 'TIME'
                         zaehl = '86400'
                         nennr = '1'
                         isocode = 'DAY'
                       )
                     ).

    go_osql_environment->insert_test_data( lt_t006 ).

    data: lt_tcurc type table of tcurc.   "Currency Codes

    "Currency Codes
    lt_tcurc = value #(
                        (
                          mandt = sy-mandt
                          waers = 'ADP'
                          isocd = 'ADP'
                          altwr = '020'
                        )
                        (
                          mandt = sy-mandt
                          waers = 'AED'
                          isocd = 'AED'
                          altwr = '784'
                        )
                        (
                          mandt = sy-mandt
                          waers = 'AFA'
                          isocd = 'AFA'
                          altwr = '004'
                        )
                        (
                          mandt = sy-mandt
                          waers = 'AFN'
                          isocd = 'AFN'
                          altwr = '971'
                        )
                      ).

    go_osql_environment->insert_test_data( lt_tcurc ).

    data: lt_t8jj type table of t8jj.   "Recovery Indicator

    "Recovery Indicator
    lt_t8jj = value #(
                       (
                         mandt = sy-mandt
                         bukrs = lcl_helper=>gc_company_cmp2
                         recid = '01'
                       )
                       (
                         mandt = sy-mandt
                         bukrs = 'YF'
                         recid = '23'
                       )
                       (
                         mandt = sy-mandt
                         bukrs = '0001'
                         recid = '12'
                       )
                       (
                         mandt = sy-mandt
                         bukrs = '0003'
                         recid = '12'
                       )
                     ).

    go_osql_environment->insert_test_data( lt_t8jj ).

    data: lt_t003 type table of t003.   "Document Types

    "Document Types
    lt_t003 = value #(
                       (
                         mandt = sy-mandt
                         blart = '01'
                         numkr = '01'
                         koars = 'ADKMS'
                         xkoaa = abap_true
                         xkoad = abap_true
                         xkoak = abap_true
                         xkoam = abap_true
                         xkoas = abap_true
                       )
                       (
                         mandt = sy-mandt
                         blart = '3P'
                         numkr = '01'
                         koars = 'ADKMS'
                         stbla = '3P'
                         xgsub = abap_true
                         xnegp = abap_true
                         xkoaa = abap_true
                         xkoad = abap_true
                         xkoak = abap_true
                         xkoam = abap_true
                         xkoas = abap_true
                         xkoasecc = abap_true
                       )
                       (
                         mandt = sy-mandt
                         blart = '7B'
                         numkr = '77'
                         koars = 'ADKMS'
                         xkoaa = abap_true
                         xkoad = abap_true
                         xkoak = abap_true
                         xkoam = abap_true
                         xkoas = abap_true
                       )
                       (
                         mandt = sy-mandt
                         blart = 'A1'
                         numkr = 'Z7'
                         koars = 'ADKMS'
                         stbla = 'AB'
                         xnetb = abap_true
                         xgsub = abap_true
                         xmges = abap_true
                         xnegp = abap_true
                         xkoaa = abap_true
                         xkoad = abap_true
                         xkoak = abap_true
                         xkoam = abap_true
                         xkoas = abap_true
                         xkoasecc = abap_true
                       )
                     ).

    go_osql_environment->insert_test_data( lt_t003 ).


  endmethod.

  method class_teardown.

  endmethod.

  method run_validation_create.

    data: lt_mpa_asset_create_data type mpa_t_asset_create.

    lt_mpa_asset_create_data =  value #( (  bukrs  = lcl_helper=>gc_company_cmp1
                                            anlkl = lcl_helper=>gc_asset_class_1100
                                            faa_md_xpostcap = abap_true
                                            anln1 = 1234
                                            anln2 = 5678
                                            txa50_anlt  = lcl_helper=>gc_asset_desc_1
                                            txa50_more = lcl_helper=>gc_asset_desc_1
                                            am_sernr  = lcl_helper=>gc_asset_sernr_101
                                            meins  = lcl_helper=>gc_unit_acr
                                            bstdt = lcl_helper=>gc_date_01_01_19
                                            invnr_anla = lcl_helper=>gc_asset_invnr_3001
                                            invzu_anla  = lcl_helper=>gc_asset_desc_1
                                            ivdat_anla  = lcl_helper=>gc_date_01_01_19
                                            inken  = abap_false
                                            kostl  = lcl_helper=>gc_kostl_kost1
                                            faa_md_wbselement = lcl_helper=>gc_wbs_0012
                                            prctr  = lcl_helper=>gc_profitcenter_prctr1
                                            fb_segment = lcl_helper=>gc_segment_segment1
                                            werks_d = lcl_helper=>gc_plantpnt1
                                            stort = lcl_helper=>gc_location_loc1
                                            raumnr = lcl_helper=>gc_room_raumnr1
                                            txjcd = lcl_helper=>gc_txjcd_txjcd1
                                            am_lifnr  = lcl_helper=>gc_vendor_vnd1
                                            xafabch = abap_true
                                            herst = lcl_helper=>gc_manufacturer_man1
                                            am_land1 = lcl_helper=>gc_country_us
                                            typbz_anla = lcl_helper=>gc_assettype_type1
                                            antei = lcl_helper=>gc_percentage_25
                                            rassc = lcl_helper=>gc_tradeid_ptn1
                                            aibn1 = lcl_helper=>gc_asset_number_1000003
                                            aibn2 = lcl_helper=>gc_num_10
                                            aibdt = lcl_helper=>gc_date_02_02_19
                                            urjhr = lcl_helper=>gc_year_2012
                                            urwrt = lcl_helper=>gc_amount_100
                                            faa_md_org_acq_curr = lcl_helper=>gc_curr_eur
                                            fins_ledger_1  = lcl_helper=>gc_ledger_0l
                                            aktivd_1  = lcl_helper=>gc_date_01_01_19
                                            fins_ledger_2  = lcl_helper=>gc_ledger_2l
                                            aktivd_2 = lcl_helper=>gc_date_02_02_19
                                            fins_ledger_3  = lcl_helper=>gc_ledger_3l
                                            aktivd_3 =  lcl_helper=>gc_date_03_03_19

                                            afaber_1 =  lcl_helper=>gc_depr_area_01
                                            afasl_1 = lcl_helper=>gc_dep_key_leax
                                            ndjar_1 = lcl_helper=>gc_num_10
                                            ndper_1  = lcl_helper=>gc_num_5
                                            adatu_1 = lcl_helper=>gc_date_01_01_19 )

                                            (  bukrs  = lcl_helper=>gc_company_cmp1
                                            anlkl = lcl_helper=>gc_asset_class_1100
                                            faa_md_xpostcap = abap_true
                                            txa50_anlt  = lcl_helper=>gc_asset_desc_1
                                            txa50_more = lcl_helper=>gc_asset_desc_1
                                            am_sernr  = lcl_helper=>gc_asset_sernr_101
                                            meins  = lcl_helper=>gc_unit_acr
                                            bstdt = lcl_helper=>gc_date_01_01_19
                                            invnr_anla = lcl_helper=>gc_asset_invnr_3001
                                            invzu_anla  = lcl_helper=>gc_asset_desc_1
                                            ivdat_anla  = lcl_helper=>gc_date_01_01_19
                                            inken  = abap_false
                                            kostl  = lcl_helper=>gc_kostl_kost1
                                            faa_md_wbselement = lcl_helper=>gc_wbs_0012
                                            prctr  = lcl_helper=>gc_profitcenter_prctr1
                                            fb_segment = lcl_helper=>gc_segment_segment1
                                            werks_d = lcl_helper=>gc_plantpnt1
                                            stort = lcl_helper=>gc_location_loc1
                                            raumnr = lcl_helper=>gc_room_raumnr1
                                            txjcd = lcl_helper=>gc_txjcd_txjcd1
                                            am_lifnr  = lcl_helper=>gc_vendor_vnd1
                                            xafabch = abap_true )
                                            (  bukrs  = lcl_helper=>gc_company_cmp2
                                            anlkl = lcl_helper=>gc_asset_class_1100
                                            faa_md_xpostcap = abap_true
                                            txa50_anlt  = lcl_helper=>gc_asset_desc_1
                                            txa50_more = lcl_helper=>gc_asset_desc_1
                                            am_sernr  = lcl_helper=>gc_asset_sernr_101
                                            meins  = lcl_helper=>gc_unit_acr
                                            bstdt = lcl_helper=>gc_date_01_01_19
                                            invnr_anla = lcl_helper=>gc_asset_invnr_3001
                                            invzu_anla  = lcl_helper=>gc_asset_desc_1
                                            ivdat_anla  = lcl_helper=>gc_date_01_01_19
                                            inken  = abap_false
                                            kostl  = lcl_helper=>gc_kostl_kost1
                                            faa_md_wbselement = lcl_helper=>gc_wbs_0012
                                            prctr  = lcl_helper=>gc_profitcenter_prctr1
                                            fb_segment = lcl_helper=>gc_segment_segment1
                                            werks_d = lcl_helper=>gc_plantpnt1
                                            stort = lcl_helper=>gc_location_loc1
                                            raumnr = lcl_helper=>gc_room_raumnr1
                                            txjcd = lcl_helper=>gc_txjcd_txjcd1
                                            am_lifnr  = lcl_helper=>gc_vendor_vnd1
                                            xafabch = abap_true ) ).

    mo_mpa_validate->if_mpa_asset_validate~validate(
      exporting
        io_mpa_output     =  mo_mpa_output
      changing
        ct_mpa_asset_data = lt_mpa_asset_create_data
    ).

  endmethod.

  method run_validation_transfer.

    data: lt_mpa_asset_transfer_data type mpa_t_asset_transfer.

    lt_mpa_asset_transfer_data =  value #( (  bukrs  = lcl_helper=>gc_company_cmp2
                                              pbukrs = lcl_helper=>gc_company_cmp1
                                              anlkl = lcl_helper=>gc_asset_class_1100
                                              anln1 = 1266
                                              anln2 = 6111
                                              panl1 = 1234
                                              panl2 = 0001
                                              blart = lcl_helper=>gc_blart_01
                                              meins  = lcl_helper=>gc_unit_acr
                                              kostl  = lcl_helper=>gc_kostl_kost1
                                              waers = 'EUR'
                                              monat = '11'
                                              acc_principle = 'IFRS'
                                              recid = lcl_helper=>gc_recid_01
                                              trava = lcl_helper=>gc_trava_0001
                                               ) ).

    mo_mpa_validate->if_mpa_asset_validate~validate(
      exporting
        io_mpa_output     =  mo_mpa_output
      changing
        ct_mpa_asset_data = lt_mpa_asset_transfer_data
    ).

  endmethod.

  method setup.

    mo_mpa_validate = new zcl_asset_validation( ).
    mo_mpa_output = cl_mpa_asset_process_factory=>get_mpa_output_instance( ).

  endmethod.

endclass.



class ltc_mpa_asset_validate definition
 for testing
  risk level harmless
  duration short.

  private section.

    data :

      mo_mpa_validate type ref to zcl_asset_validation,
      mo_mpa_output   type ref to if_mpa_output.

    class-methods :

      class_setup,
      class_teardown.

    methods :
      setup ,
      teardown,
      get_validating_fieldnames for testing,
      add_result_status_and_summary for testing,
      if_validate_negative_fieldlist for testing,
      if_validate_negative_status for testing raising cx_static_check.


endclass.

class ltc_mpa_asset_validate implementation.

  method class_setup.

    cl_mpa_asset_process_injector=>inject_mpa_output_instance( ).

  endmethod.

  method get_validating_fieldnames.

    data(lt_exp_fieldname) = value zcl_asset_validation=>gty_t_range_fieldname( ( sign =  zcl_asset_validation=>gc_sign_include
                                                                                    option =  zcl_asset_validation=>gc_option_equal
                                                                                    low =  zcl_asset_validation=>gc_field_name-bukrs )
                                                                                  ( sign =  zcl_asset_validation=>gc_sign_include
                                                                                    option =  zcl_asset_validation=>gc_option_equal
                                                                                    low =  zcl_asset_validation=>gc_field_name-pbukrs )
                                                                                  ( sign =  zcl_asset_validation=>gc_sign_include
                                                                                    option =  zcl_asset_validation=>gc_option_equal
                                                                                    low =  zcl_asset_validation=>gc_field_name-anlkl )
                                                                                  ( sign =  zcl_asset_validation=>gc_sign_include
                                                                                    option =  zcl_asset_validation=>gc_option_equal
                                                                                    low =  zcl_asset_validation=>gc_field_name-fins_ledger_1 )
                                                                                  ( sign =  zcl_asset_validation=>gc_sign_include
                                                                                    option =  zcl_asset_validation=>gc_option_equal
                                                                                    low =  zcl_asset_validation=>gc_field_name-fins_ledger_2 )
                                                                                  ( sign =  zcl_asset_validation=>gc_sign_include
                                                                                    option =  zcl_asset_validation=>gc_option_equal
                                                                                    low =  zcl_asset_validation=>gc_field_name-fins_ledger_3 )
                                                                                  ( sign =  zcl_asset_validation=>gc_sign_include
                                                                                    option =  zcl_asset_validation=>gc_option_equal
                                                                                    low =  zcl_asset_validation=>gc_field_name-fins_ledger_4 )
                                                                                  ( sign =  zcl_asset_validation=>gc_sign_include
                                                                                    option =  zcl_asset_validation=>gc_option_equal
                                                                                    low =  zcl_asset_validation=>gc_field_name-fins_ledger_5 )
                                                                                  ( sign =  zcl_asset_validation=>gc_sign_include
                                                                                    option =  zcl_asset_validation=>gc_option_equal
                                                                                    low =  zcl_asset_validation=>gc_field_name-afaber_1 )
                                                                                  ( sign =  zcl_asset_validation=>gc_sign_include
                                                                                    option =  zcl_asset_validation=>gc_option_equal
                                                                                    low =  zcl_asset_validation=>gc_field_name-afaber_2 )
                                                                                  ( sign =  zcl_asset_validation=>gc_sign_include
                                                                                    option =  zcl_asset_validation=>gc_option_equal
                                                                                    low =  zcl_asset_validation=>gc_field_name-afaber_3 )
                                                                                  ( sign =  zcl_asset_validation=>gc_sign_include
                                                                                    option =  zcl_asset_validation=>gc_option_equal
                                                                                    low =  zcl_asset_validation=>gc_field_name-afaber_4 )
                                                                                  ( sign =  zcl_asset_validation=>gc_sign_include
                                                                                    option =  zcl_asset_validation=>gc_option_equal
                                                                                    low =  zcl_asset_validation=>gc_field_name-afaber_5 )
                                                                                  ( sign =  zcl_asset_validation=>gc_sign_include
                                                                                    option =  zcl_asset_validation=>gc_option_equal
                                                                                    low =  zcl_asset_validation=>gc_field_name-anln1 )
                                                                                  ( sign =  zcl_asset_validation=>gc_sign_include
                                                                                    option =  zcl_asset_validation=>gc_option_equal
                                                                                    low =  zcl_asset_validation=>gc_field_name-panl1 )
                                                                                  ( sign =  zcl_asset_validation=>gc_sign_include
                                                                                    option =  zcl_asset_validation=>gc_option_equal
                                                                                    low =  zcl_asset_validation=>gc_field_name-anln2 )
                                                                                  ( sign =  zcl_asset_validation=>gc_sign_include
                                                                                    option =  zcl_asset_validation=>gc_option_equal
                                                                                    low =  zcl_asset_validation=>gc_field_name-panl2 )
                                                                                  ( sign =  zcl_asset_validation=>gc_sign_include
                                                                                    option =  zcl_asset_validation=>gc_option_equal
                                                                                    low =  zcl_asset_validation=>gc_field_name-kostl )
                                                                                  ( sign =  zcl_asset_validation=>gc_sign_include
                                                                                    option =  zcl_asset_validation=>gc_option_equal
                                                                                    low =  zcl_asset_validation=>gc_field_name-meins )
                                                                                  ( sign =  zcl_asset_validation=>gc_sign_include
                                                                                    option =  zcl_asset_validation=>gc_option_equal
                                                                                    low =  zcl_asset_validation=>gc_field_name-waers )
                                                                                  ( sign =  zcl_asset_validation=>gc_sign_include
                                                                                    option =  zcl_asset_validation=>gc_option_equal
                                                                                    low =  zcl_asset_validation=>gc_field_name-monat )
                                                                                  ( sign =  zcl_asset_validation=>gc_sign_include
                                                                                    option =  zcl_asset_validation=>gc_option_equal
                                                                                    low =  zcl_asset_validation=>gc_field_name-adatu_1 )
                                                                                  ( sign =  zcl_asset_validation=>gc_sign_include
                                                                                    option =  zcl_asset_validation=>gc_option_equal
                                                                                    low =  zcl_asset_validation=>gc_field_name-adatu_2 )
                                                                                  ( sign =  zcl_asset_validation=>gc_sign_include
                                                                                    option =  zcl_asset_validation=>gc_option_equal
                                                                                    low =  zcl_asset_validation=>gc_field_name-adatu_3 )
                                                                                  ( sign =  zcl_asset_validation=>gc_sign_include
                                                                                    option =  zcl_asset_validation=>gc_option_equal
                                                                                    low =  zcl_asset_validation=>gc_field_name-adatu_4 )
                                                                                  ( sign =  zcl_asset_validation=>gc_sign_include
                                                                                    option =  zcl_asset_validation=>gc_option_equal
                                                                                    low =  zcl_asset_validation=>gc_field_name-adatu_5 )
                                                                                  ( sign =  zcl_asset_validation=>gc_sign_include
                                                                                    option =  zcl_asset_validation=>gc_option_equal
                                                                                    low =  zcl_asset_validation=>gc_field_name-am_land1 )
                                                                                  ( sign =  zcl_asset_validation=>gc_sign_include
                                                                                    option =  zcl_asset_validation=>gc_option_equal
                                                                                    low =  zcl_asset_validation=>gc_field_name-werks_d )
                                                                                  ( sign =  zcl_asset_validation=>gc_sign_include
                                                                                    option =  zcl_asset_validation=>gc_option_equal
                                                                                    low =  zcl_asset_validation=>gc_field_name-rassc )
                                                                                  ( sign =  zcl_asset_validation=>gc_sign_include
                                                                                    option =  zcl_asset_validation=>gc_option_equal
                                                                                    low =  zcl_asset_validation=>gc_field_name-acc_principle )
                                                                                 ( sign = zcl_asset_validation=>gc_sign_include
                                                                                    option = zcl_asset_validation=>gc_option_equal
                                                                                    low = zcl_asset_validation=>gc_field_name-trava )
                                                                                  ( sign = zcl_asset_validation=>gc_sign_include
                                                                                    option = zcl_asset_validation=>gc_option_equal
                                                                                    low = zcl_asset_validation=>gc_field_name-blart )
                                                                                  ( sign = zcl_asset_validation=>gc_sign_include
                                                                                    option = zcl_asset_validation=>gc_option_equal
                                                                                    low = zcl_asset_validation=>gc_field_name-recid ) ).

    "when
    data(lt_act_fieldname) = mo_mpa_validate->get_validating_fieldnames( ).

    "then
    cl_abap_unit_assert=>assert_equals( act  = lt_act_fieldname
                                        quit = if_aunit_constants=>quit-no
                                        exp = lt_exp_fieldname ).

  endmethod.


  method setup.

    mo_mpa_validate = new zcl_asset_validation( ).
    mo_mpa_output = cl_mpa_asset_process_factory=>get_mpa_output_instance( ).

  endmethod.

  method add_result_status_and_summary.

    data: lt_mpa_asset_create_data type mpa_t_asset_create,
          lt_invalid_rows          type zcl_asset_validation=>gty_t_row_number.

    lt_mpa_asset_create_data =  value #( (  bukrs  = lcl_helper=>gc_company_cmp1
                                            anlkl = lcl_helper=>gc_asset_class_1100
                                            faa_md_xpostcap = abap_true
                                            txa50_anlt  = lcl_helper=>gc_asset_desc_1
                                            txa50_more = lcl_helper=>gc_asset_desc_1
                                            am_sernr  = lcl_helper=>gc_asset_sernr_101
                                            meins  = lcl_helper=>gc_unit_acr
                                            bstdt = lcl_helper=>gc_date_01_01_19
                                            invnr_anla = lcl_helper=>gc_asset_invnr_3001
                                            invzu_anla  = lcl_helper=>gc_asset_desc_1
                                            ivdat_anla  = lcl_helper=>gc_date_01_01_19
                                            inken  = abap_false
                                            kostl  = lcl_helper=>gc_kostl_kost1
                                            faa_md_wbselement = lcl_helper=>gc_wbs_0012
                                            prctr  = lcl_helper=>gc_profitcenter_prctr1
                                            fb_segment = lcl_helper=>gc_segment_segment1
                                            werks_d = lcl_helper=>gc_plantpnt1
                                            stort = lcl_helper=>gc_location_loc1
                                            raumnr = lcl_helper=>gc_room_raumnr1
                                            txjcd = lcl_helper=>gc_txjcd_txjcd1
                                            am_lifnr  = lcl_helper=>gc_vendor_vnd1
                                            xafabch = abap_true
                                            herst = lcl_helper=>gc_manufacturer_man1
                                            am_land1 = lcl_helper=>gc_country_us
                                            typbz_anla = lcl_helper=>gc_assettype_type1
                                            antei = lcl_helper=>gc_percentage_25
                                            rassc = lcl_helper=>gc_tradeid_ptn1
                                            aibn1 = lcl_helper=>gc_asset_number_1000003
                                            aibn2 = lcl_helper=>gc_num_10
                                            aibdt = lcl_helper=>gc_date_02_02_19
                                            urjhr = lcl_helper=>gc_year_2012
                                            urwrt = lcl_helper=>gc_amount_100
                                            faa_md_org_acq_curr = lcl_helper=>gc_curr_eur
                                            fins_ledger_1  = lcl_helper=>gc_ledger_0l
                                            aktivd_1  = lcl_helper=>gc_date_01_01_19
                                            fins_ledger_2  = lcl_helper=>gc_ledger_2l
                                            aktivd_2 = lcl_helper=>gc_date_02_02_19
                                            fins_ledger_3  = lcl_helper=>gc_ledger_3l
                                            aktivd_3 =  lcl_helper=>gc_date_03_03_19

                                            afaber_1 =  lcl_helper=>gc_depr_area_01
                                            afasl_1 = lcl_helper=>gc_dep_key_leax
                                            ndjar_1 = lcl_helper=>gc_num_10
                                            ndper_1  = lcl_helper=>gc_num_5
                                            adatu_1 = lcl_helper=>gc_date_01_01_19 )

                                            (  bukrs  = lcl_helper=>gc_company_cmp1
                                            anlkl = lcl_helper=>gc_asset_class_1100
                                            faa_md_xpostcap = abap_true
                                            txa50_anlt  = lcl_helper=>gc_asset_desc_1
                                            txa50_more = lcl_helper=>gc_asset_desc_1
                                            am_sernr  = lcl_helper=>gc_asset_sernr_101
                                            meins  = lcl_helper=>gc_unit_acr
                                            bstdt = lcl_helper=>gc_date_01_01_19
                                            invnr_anla = lcl_helper=>gc_asset_invnr_3001
                                            invzu_anla  = lcl_helper=>gc_asset_desc_1
                                            ivdat_anla  = lcl_helper=>gc_date_01_01_19
                                            inken  = abap_false
                                            kostl  = lcl_helper=>gc_kostl_kost1
                                            faa_md_wbselement = lcl_helper=>gc_wbs_0012
                                            prctr  = lcl_helper=>gc_profitcenter_prctr1
                                            fb_segment = lcl_helper=>gc_segment_segment1
                                            werks_d = lcl_helper=>gc_plantpnt1
                                            stort = lcl_helper=>gc_location_loc1
                                            raumnr = lcl_helper=>gc_room_raumnr1
                                            txjcd = lcl_helper=>gc_txjcd_txjcd1
                                            am_lifnr  = lcl_helper=>gc_vendor_vnd1
                                            xafabch = abap_true )
                                            (  bukrs  = lcl_helper=>gc_company_cmp2
                                            anlkl = lcl_helper=>gc_asset_class_1100
                                            faa_md_xpostcap = abap_true
                                            txa50_anlt  = lcl_helper=>gc_asset_desc_1
                                            txa50_more = lcl_helper=>gc_asset_desc_1
                                            am_sernr  = lcl_helper=>gc_asset_sernr_101
                                            meins  = lcl_helper=>gc_unit_acr
                                            bstdt = lcl_helper=>gc_date_01_01_19
                                            invnr_anla = lcl_helper=>gc_asset_invnr_3001
                                            invzu_anla  = lcl_helper=>gc_asset_desc_1
                                            ivdat_anla  = lcl_helper=>gc_date_01_01_19
                                            inken  = abap_false
                                            kostl  = lcl_helper=>gc_kostl_kost1
                                            faa_md_wbselement = lcl_helper=>gc_wbs_0012
                                            prctr  = lcl_helper=>gc_profitcenter_prctr1
                                            fb_segment = lcl_helper=>gc_segment_segment1
                                            werks_d = lcl_helper=>gc_plantpnt1
                                            stort = lcl_helper=>gc_location_loc1
                                            raumnr = lcl_helper=>gc_room_raumnr1
                                            txjcd = lcl_helper=>gc_txjcd_txjcd1
                                            am_lifnr  = lcl_helper=>gc_vendor_vnd1
                                            xafabch = abap_true ) ).


    lt_invalid_rows = value #( ( row = 1 )
                               ( row = 3 ) ).

    "when
    mo_mpa_validate->change_itab_status_build_smmry( exporting io_mpa_output     = mo_mpa_output
                                                              it_invalid_row    = lt_invalid_rows
                                                     changing ct_mpa_asset_data = lt_mpa_asset_create_data ).

*    LOOP AT lt_mpa_asset_create_data REFERENCE INTO DATA(lr_mpa_asset_create_data).
*      "then
*      cl_abap_unit_assert=>assert_equals( EXPORTING  act                  = lr_mpa_asset_create_data->status
*                                                     exp                  = COND #( WHEN line_exists( lt_invalid_rows[ sy-tabix ] )
*                                                                                    THEN if_mpa_output=>gc_msg_type-error )
*                                                     quit                 = if_abap_unit_constant=>quit-no ).
*    ENDLOOP.

    cl_abap_unit_assert=>assert_equals( exporting  act                  =  lines( mo_mpa_output->get_summary_messages( ) )
                                                   exp                  = lines( lt_invalid_rows )
                                                   quit                 = if_abap_unit_constant=>quit-no ).

  endmethod.

  method class_teardown.

    cl_mpa_asset_process_injector=>use_default_mpa_output_instanc( ).

  endmethod.

  method if_validate_negative_fieldlist.

    data lt_data type table of acdoca.

    mo_mpa_validate->if_mpa_asset_validate~validate(
      exporting
        io_mpa_output        = mo_mpa_output
*    iv_write_into_applog = abap_true
      changing
        ct_mpa_asset_data    =  lt_data
    ).

    cl_abap_unit_assert=>assert_equals( act  = mo_mpa_output->get_app_log_msg_logger( )->get_msg_count( )
                                        quit = if_aunit_constants=>quit-no
                                        exp = 0 ).

  endmethod.

  method if_validate_negative_status.

    data(lt_data) = value mpa_t_asset_create( ( status = 'E'
                                                bukrs = lcl_helper=>gc_company_cmp1  )
                                              ( status = 'A'
                                                bukrs = lcl_helper=>gc_company_cmp2  )  ).

    mo_mpa_validate->if_mpa_asset_validate~validate(
      exporting
        io_mpa_output        = mo_mpa_output
*    iv_write_into_applog = abap_true
      changing
        ct_mpa_asset_data    =  lt_data
    ).

    cl_abap_unit_assert=>assert_equals( act  = mo_mpa_output->get_app_log_msg_logger( )->get_msg_count( )
                                        quit = if_aunit_constants=>quit-no
                                        exp = 0 ).

  endmethod.

  method teardown.

    cl_mpa_asset_process_injector=>use_default_mpa_output_instanc( ).

  endmethod.

endclass.

class ltc_bukrs definition
 for testing
  risk level harmless
  duration short.

  private section.

    class-methods :

      class_setup,
      class_teardown.

    data : mo_cut        type ref to lcl_bukrs,
           mo_mpa_output type ref to if_mpa_output.

    methods :
      setup ,
      teardown,
      get_range for testing,
      insert for testing,
      validate_neg_test_exception for testing,
      validate_negative_test_error for testing raising cx_static_check.

endclass.

class ltc_bukrs implementation.

  method class_setup.



  endmethod.

  method class_teardown.

  endmethod.

  method setup.

    mo_cut = new lcl_bukrs( ).
    mo_mpa_output = new cl_mpa_output_spy( ).

    mo_cut->mo_faa_cfg_access = new ltd_faa_cfg_access( ).

  endmethod.

  method get_range.

    data lt_bukrs_range type range of bukrs.

    lt_bukrs_range = value #( ( sign = zcl_asset_validation=>gc_sign_include
                                option = zcl_asset_validation=>gc_option_equal
                                low = lcl_helper=>gc_company_cmp1 )
                              ( sign = zcl_asset_validation=>gc_sign_include
                                option = zcl_asset_validation=>gc_option_equal
                                low = lcl_helper=>gc_company_cmp2 ) ).

    "given
    mo_cut->mt_bukrs_range = lt_bukrs_range.

    "when then
    cl_abap_unit_assert=>assert_equals( act  = mo_cut->get_range( )
                                        quit = if_aunit_constants=>quit-no
                                        exp = lt_bukrs_range ).

  endmethod.


  method insert.

    "when
    mo_cut->insert(
      exporting
        iv_index         = 3
        iv_value         = lcl_helper=>gc_company_cmp1
        io_mpa_output    = mo_mpa_output   ).

    "then

    cl_abap_unit_assert=>assert_equals( act  = mo_cut->mt_bukrs
                                        quit = if_aunit_constants=>quit-no
                                        exp = value lcl_bukrs=>gty_tt_index_bukrs( ( index = 3
                                                                                     bukrs = lcl_helper=>gc_company_cmp1 )  ) ).

  endmethod.

  method validate_neg_test_exception.

    "given
    mo_cut->mt_bukrs = value #( ( index = 1
                                  bukrs = lcl_helper=>gc_company_cmp2 ) ).

    "when
    mo_cut->validate( io_mpa_output = mo_mpa_output ).

    mo_mpa_output->save_app_log_message( ).
    "then
    cl_abap_unit_assert=>assert_equals( act  = mo_mpa_output->get_app_log_msg_logger( )->get_msg_count( )
                                        quit = if_aunit_constants=>quit-no
                                        exp = 2 ).

  endmethod.

  method validate_negative_test_error.

    "when 1
    mo_cut->validate( io_mpa_output = mo_mpa_output ).

    mo_mpa_output->save_app_log_message( ).
    "then 1
    cl_abap_unit_assert=>assert_initial( act  = mo_mpa_output->get_app_log_msg_logger( )->get_msg_count( )
                                         quit = if_aunit_constants=>quit-no  ).

    "given 1
    mo_cut->mt_bukrs = value #( ( index = 1
                                  bukrs = lcl_helper=>gc_company_cmp1 ) ).

    "when 1
    mo_cut->validate( io_mpa_output = mo_mpa_output ).

    mo_mpa_output->save_app_log_message( ).
    "then 1
    cl_abap_unit_assert=>assert_equals( act  = mo_mpa_output->get_app_log_msg_logger( )->get_msg_count( )
                                        quit = if_aunit_constants=>quit-no
                                        exp = 2 ).

  endmethod.

  method teardown.
    cl_mpa_asset_process_injector=>use_default_mpa_output_instanc( ).
  endmethod.

endclass.

class ltc_pbukrs definition
 for testing
  risk level harmless
  duration short.

  private section.

    class-methods :

      class_setup,
      class_teardown.

    data : mo_cut        type ref to lcl_pbukrs,
           mo_mpa_output type ref to if_mpa_output.

    methods :
      setup ,
      teardown,
      validate_negative_test for testing.

endclass.

class ltc_pbukrs implementation.

  method class_setup.

  endmethod.

  method class_teardown.

  endmethod.

  method setup.

    mo_cut = new lcl_pbukrs( ).
    mo_mpa_output = new cl_mpa_output_spy( ).

    mo_cut->mo_faa_cfg_access = new ltd_faa_cfg_access( ).

  endmethod.

  method validate_negative_test.

    "when 1
    mo_cut->validate( io_mpa_output = mo_mpa_output ).

    mo_mpa_output->save_app_log_message( ).
    "then 1
    cl_abap_unit_assert=>assert_initial( act  = mo_mpa_output->get_app_log_msg_logger( )->get_msg_count( )
                                         quit = if_aunit_constants=>quit-no ).

    "given 2
    mo_cut->mt_pbukrs = value #( ( index = 1
                                   pbukrs = lcl_helper=>gc_company_cmp2 ) ).

    "when 2
    mo_cut->validate( io_mpa_output = mo_mpa_output ).

    mo_mpa_output->save_app_log_message( ).
    "then 2
    cl_abap_unit_assert=>assert_equals( act  = mo_mpa_output->get_app_log_msg_logger( )->get_msg_count( )
                                        quit = if_aunit_constants=>quit-no
                                        exp = 2 ).

  endmethod.

  method teardown.
    cl_mpa_asset_process_injector=>use_default_mpa_output_instanc( ).
  endmethod.

endclass.

class ltc_acc_principle definition
 for testing
  risk level harmless
  duration short.

  private section.

    class-methods :

      class_setup,
      class_teardown.

    data : mo_cut        type ref to lcl_acc_principle,
           mo_mpa_output type ref to if_mpa_output.

    methods :
      setup ,
      teardown,
      validate_negative_test for testing.

endclass.

class ltc_acc_principle implementation.

  method class_setup.

  endmethod.

  method class_teardown.

  endmethod.

  method setup.

    mo_cut = new lcl_acc_principle( ).
    mo_mpa_output = new cl_mpa_output_spy( ).

    mo_cut->mo_faa_cfg_access = new ltd_faa_cfg_access( ).

  endmethod.

  method validate_negative_test.

    "given
    mo_cut->mt_acc_principle = value #( ( index = 1
                                          accounting_principle = lcl_helper=>gc_acc_principle_ifrs ) ).

    "when
    mo_cut->validate( io_mpa_output = mo_mpa_output ).

    mo_mpa_output->save_app_log_message( ).
    "then
    cl_abap_unit_assert=>assert_equals( act  = mo_mpa_output->get_app_log_msg_logger( )->get_msg_count( )
                                        quit = if_aunit_constants=>quit-no
                                        exp = 2 ).

  endmethod.

  method teardown.
    cl_mpa_asset_process_injector=>use_default_mpa_output_instanc( ).
  endmethod.

endclass.

class ltc_anln1 definition
 for testing
  risk level harmless
  duration short .

  private section.

    class-methods :

      class_setup,
      class_teardown.

    data : mo_cut        type ref to lcl_anln1,
           mo_mpa_output type ref to if_mpa_output.

    methods :
      setup ,
      teardown,
      validate_negative_test for testing.

endclass.

class ltc_anln1 implementation.

  method class_setup.

  endmethod.

  method class_teardown.

  endmethod.

  method setup.

    mo_cut = new lcl_anln1( ).
    mo_mpa_output = new cl_mpa_output_spy( ).

  endmethod.

  method validate_negative_test.

    "when
    mo_cut->validate( io_mpa_output = mo_mpa_output ).

    mo_mpa_output->save_app_log_message( ).
    "then
    cl_abap_unit_assert=>assert_initial( act  = mo_mpa_output->get_app_log_msg_logger( )->get_msg_count( )
                                         quit = if_aunit_constants=>quit-no ).

  endmethod.

  method teardown.
    cl_mpa_asset_process_injector=>use_default_mpa_output_instanc( ).
  endmethod.

endclass.

class ltc_anln2 definition
 for testing
  risk level harmless
  duration short .

  private section.

    class-methods :

      class_setup,
      class_teardown.

    data : mo_cut        type ref to lcl_anln2,
           mo_mpa_output type ref to if_mpa_output.

    methods :
      setup ,
      teardown,
      validate_negative_test for testing.

endclass.

class ltc_anln2 implementation.

  method class_setup.

  endmethod.

  method class_teardown.

  endmethod.

  method setup.

    mo_cut = new lcl_anln2( ).
    mo_mpa_output = new cl_mpa_output_spy( ).

  endmethod.

  method validate_negative_test.

    "when
    mo_cut->validate( io_mpa_output = mo_mpa_output ).

    mo_mpa_output->save_app_log_message( ).
    "then
    cl_abap_unit_assert=>assert_initial( act  = mo_mpa_output->get_app_log_msg_logger( )->get_msg_count( )
                                         quit = if_aunit_constants=>quit-no ).

  endmethod.

  method teardown.
    cl_mpa_asset_process_injector=>use_default_mpa_output_instanc( ).
  endmethod.

endclass.

class ltc_blart definition
 for testing
  risk level harmless
  duration short .

  private section.

    class-methods :

      class_setup,
      class_teardown.

    data : mo_cut        type ref to lcl_blart,
           mo_mpa_output type ref to if_mpa_output.

    methods :
      setup ,
      teardown,
      validate_negative_test for testing.

endclass.

class ltc_blart implementation.

  method class_setup.

  endmethod.

  method class_teardown.

  endmethod.

  method setup.

    mo_cut = new lcl_blart( ).
    mo_mpa_output = new cl_mpa_output_spy( ).

  endmethod.

  method validate_negative_test.

    "when
    mo_cut->validate( io_mpa_output = mo_mpa_output ).

    mo_mpa_output->save_app_log_message( ).
    "then
    cl_abap_unit_assert=>assert_initial( act  = mo_mpa_output->get_app_log_msg_logger( )->get_msg_count( )
                                         quit = if_aunit_constants=>quit-no ).

  endmethod.

  method teardown.
    cl_mpa_asset_process_injector=>use_default_mpa_output_instanc( ).
  endmethod.

endclass.

class ltc_kostl definition
 for testing
  risk level harmless
  duration short .

  private section.

    class-methods :

      class_setup,
      class_teardown.

    data : mo_cut        type ref to lcl_kostl,
           mo_mpa_output type ref to if_mpa_output.

    methods :
      setup ,
      teardown,
      validate_negative_test for testing.

endclass.

class ltc_kostl implementation.

  method class_setup.

  endmethod.

  method class_teardown.

  endmethod.

  method setup.

    mo_cut = new lcl_kostl( ).
    mo_mpa_output = new cl_mpa_output_spy( ).

  endmethod.

  method validate_negative_test.

    "when
    mo_cut->validate( io_mpa_output = mo_mpa_output ).

    mo_mpa_output->save_app_log_message( ).
    "then
    cl_abap_unit_assert=>assert_initial( act  = mo_mpa_output->get_app_log_msg_logger( )->get_msg_count( )
                                         quit = if_aunit_constants=>quit-no ).

  endmethod.

  method teardown.
    cl_mpa_asset_process_injector=>use_default_mpa_output_instanc( ).
  endmethod.

endclass.

class ltc_meins definition
 for testing
  risk level harmless
  duration short .

  private section.

    class-methods :

      class_setup,
      class_teardown.

    data : mo_cut        type ref to lcl_meins,
           mo_mpa_output type ref to if_mpa_output.

    methods :
      setup ,
      teardown,
      validate_negative_test for testing.

endclass.

class ltc_meins implementation.

  method class_setup.

  endmethod.

  method class_teardown.

  endmethod.

  method setup.

    mo_cut = new lcl_meins( ).
    mo_mpa_output = new cl_mpa_output_spy( ).

  endmethod.

  method validate_negative_test.

    "when
    mo_cut->validate( io_mpa_output = mo_mpa_output ).

    mo_mpa_output->save_app_log_message( ).
    "then
    cl_abap_unit_assert=>assert_initial( act  = mo_mpa_output->get_app_log_msg_logger( )->get_msg_count( )
                                         quit = if_aunit_constants=>quit-no ).

  endmethod.

  method teardown.
    cl_mpa_asset_process_injector=>use_default_mpa_output_instanc( ).
  endmethod.

endclass.

class ltc_panl1 definition
 for testing
  risk level harmless
  duration short .

  private section.

    class-methods :

      class_setup,
      class_teardown.

    data : mo_cut        type ref to lcl_panl1,
           mo_mpa_output type ref to if_mpa_output.

    methods :
      setup ,
      teardown,
      validate_negative_test for testing.

endclass.

class ltc_panl1 implementation.

  method class_setup.

  endmethod.

  method class_teardown.

  endmethod.

  method setup.

    mo_cut = new lcl_panl1( ).
    mo_mpa_output = new cl_mpa_output_spy( ).

  endmethod.

  method validate_negative_test.

    "when
    mo_cut->validate( io_mpa_output = mo_mpa_output ).

    mo_mpa_output->save_app_log_message( ).
    "then
    cl_abap_unit_assert=>assert_initial( act  = mo_mpa_output->get_app_log_msg_logger( )->get_msg_count( )
                                         quit = if_aunit_constants=>quit-no ).

  endmethod.

  method teardown.
    cl_mpa_asset_process_injector=>use_default_mpa_output_instanc( ).
  endmethod.

endclass.

class ltc_panl2 definition
 for testing
  risk level harmless
  duration short .

  private section.

    class-methods :

      class_setup,
      class_teardown.

    data : mo_cut        type ref to lcl_panl2,
           mo_mpa_output type ref to if_mpa_output.

    methods :
      setup ,
      teardown,
      validate_negative_test for testing.

endclass.

class ltc_panl2 implementation.

  method class_setup.

  endmethod.

  method class_teardown.

  endmethod.

  method setup.

    mo_cut = new lcl_panl2( ).
    mo_mpa_output = new cl_mpa_output_spy( ).

  endmethod.

  method validate_negative_test.

    "when
    mo_cut->validate( io_mpa_output = mo_mpa_output ).

    mo_mpa_output->save_app_log_message( ).
    "then
    cl_abap_unit_assert=>assert_initial( act  = mo_mpa_output->get_app_log_msg_logger( )->get_msg_count( )
                                         quit = if_aunit_constants=>quit-no ).

  endmethod.

  method teardown.
    cl_mpa_asset_process_injector=>use_default_mpa_output_instanc( ).
  endmethod.

endclass.

class ltc_rassc definition
 for testing
  risk level harmless
  duration short .

  private section.

    class-methods :

      class_setup,
      class_teardown.

    data : mo_cut        type ref to lcl_rassc,
           mo_mpa_output type ref to if_mpa_output.

    methods :
      setup ,
      teardown,
      validate_negative_test for testing.

endclass.

class ltc_rassc implementation.

  method class_setup.

  endmethod.

  method class_teardown.

  endmethod.

  method setup.

    mo_cut = new lcl_rassc( ).
    mo_mpa_output = new cl_mpa_output_spy( ).

  endmethod.

  method validate_negative_test.

    "when
    mo_cut->validate( io_mpa_output = mo_mpa_output ).

    mo_mpa_output->save_app_log_message( ).
    "then
    cl_abap_unit_assert=>assert_initial( act  = mo_mpa_output->get_app_log_msg_logger( )->get_msg_count( )
                                         quit = if_aunit_constants=>quit-no ).

  endmethod.

  method teardown.
    cl_mpa_asset_process_injector=>use_default_mpa_output_instanc( ).
  endmethod.

endclass.

class ltc_recid definition
 for testing
  risk level harmless
  duration short .

  private section.

    class-methods :

      class_setup,
      class_teardown.

    data : mo_cut        type ref to lcl_recid,
           mo_mpa_output type ref to if_mpa_output.

    methods :
      setup ,
      teardown,
      validate_negative_test for testing.

endclass.

class ltc_recid implementation.

  method class_setup.

  endmethod.

  method class_teardown.

  endmethod.

  method setup.

    mo_cut = new lcl_recid( ).
    mo_mpa_output = new cl_mpa_output_spy( ).

  endmethod.

  method validate_negative_test.

    "when
    mo_cut->validate( io_mpa_output = mo_mpa_output ).

    mo_mpa_output->save_app_log_message( ).
    "then
    cl_abap_unit_assert=>assert_initial( act  = mo_mpa_output->get_app_log_msg_logger( )->get_msg_count( )
                                         quit = if_aunit_constants=>quit-no ).

  endmethod.

  method teardown.
    cl_mpa_asset_process_injector=>use_default_mpa_output_instanc( ).
  endmethod.

endclass.

class ltc_trava definition
 for testing
  risk level harmless
  duration short .

  private section.

    class-methods :

      class_setup,
      class_teardown.

    data : mo_cut        type ref to lcl_trava,
           mo_mpa_output type ref to if_mpa_output.

    methods :
      setup ,
      teardown,
      validate_negative_test for testing.

endclass.

class ltc_trava implementation.

  method class_setup.

  endmethod.

  method class_teardown.

  endmethod.

  method setup.

    mo_cut = new lcl_trava( ).
    mo_mpa_output = new cl_mpa_output_spy( ).

  endmethod.

  method validate_negative_test.

    "when
    mo_cut->validate( io_mpa_output = mo_mpa_output ).

    mo_mpa_output->save_app_log_message( ).
    "then
    cl_abap_unit_assert=>assert_initial( act  = mo_mpa_output->get_app_log_msg_logger( )->get_msg_count( )
                                         quit = if_aunit_constants=>quit-no ).

  endmethod.

  method teardown.
    cl_mpa_asset_process_injector=>use_default_mpa_output_instanc( ).
  endmethod.

endclass.

class ltc_waers definition
 for testing
  risk level harmless
  duration short .

  private section.

    class-methods :

      class_setup,
      class_teardown.

    data : mo_cut        type ref to lcl_waers,
           mo_mpa_output type ref to if_mpa_output.

    methods :
      setup ,
      teardown,
      validate_negative_test for testing.

endclass.

class ltc_waers implementation.

  method class_setup.

  endmethod.

  method class_teardown.

  endmethod.

  method setup.

    mo_cut = new lcl_waers( ).
    mo_mpa_output = new cl_mpa_output_spy( ).

  endmethod.

  method validate_negative_test.

    "when
    mo_cut->validate( io_mpa_output = mo_mpa_output ).

    mo_mpa_output->save_app_log_message( ).
    "then
    cl_abap_unit_assert=>assert_initial( act  = mo_mpa_output->get_app_log_msg_logger( )->get_msg_count( )
                                         quit = if_aunit_constants=>quit-no ).

  endmethod.

  method teardown.
    cl_mpa_asset_process_injector=>use_default_mpa_output_instanc( ).
  endmethod.

endclass.

class ltc_werks_d definition
 for testing
  risk level harmless
  duration short .

  private section.

    class-methods :

      class_setup,
      class_teardown.

    data : mo_cut        type ref to lcl_werks_d,
           mo_mpa_output type ref to if_mpa_output.

    methods :
      setup ,
      teardown,
      validate_negative_test for testing.

endclass.

class ltc_werks_d implementation.

  method class_setup.

  endmethod.

  method class_teardown.

  endmethod.

  method setup.

    mo_cut = new lcl_werks_d( ).
    mo_mpa_output = new cl_mpa_output_spy( ).

  endmethod.

  method validate_negative_test.

    "when
    mo_cut->validate( io_mpa_output = mo_mpa_output ).

    mo_mpa_output->save_app_log_message( ).
    "then
    cl_abap_unit_assert=>assert_initial( act  = mo_mpa_output->get_app_log_msg_logger( )->get_msg_count( )
                                         quit = if_aunit_constants=>quit-no ).

  endmethod.

  method teardown.
    cl_mpa_asset_process_injector=>use_default_mpa_output_instanc( ).
  endmethod.

endclass.
