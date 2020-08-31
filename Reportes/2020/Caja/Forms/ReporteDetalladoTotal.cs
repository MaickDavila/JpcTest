using Microsoft.Reporting.WinForms;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Presentacion.Reportes._2020.Caja.Forms
{
    public partial class ReporteDetalladoTotal : Imprimir
    {
        private int IdApertura = 0;
        public ReporteDetalladoTotal()
        {
            InitializeComponent();
        }
        public ReporteDetalladoTotal(int idapertura)
        {
            InitializeComponent();
            IdApertura =  idapertura;
        }

        private void ReporteDetalladoTotal_Load(object sender, EventArgs e)
        {           
            Pisos();
            Previsualizar();
            //Close();
        }
        void Previsualizar()
        {
            try
            {
               



                ListaPisos.Add(0);
                int pisos = ListaPisos.Count;

                if (ListaPisos.Count <= 2)
                {

                    pisos = 1;
                }
                AsignarRutaReporte();

                for (int i = 0; i < pisos; i++)
                {
                    int index_piso = ListaPisos.ToArray().Length;
                    index_piso--;

                    string reporte = "2020\\Caja\\";
                    reporte += "reporteDetalladoTotal.rdlc";
                    //

                    LLenar_2();

                    DataSetDetalleTotalTableAdapters.spReporteDetalladoTotalTableAdapter ta = new DataSetDetalleTotalTableAdapters.spReporteDetalladoTotalTableAdapter();
                    ta.Connection = new System.Data.SqlClient.SqlConnection(DataSetConexion);

                    DataSetDetalleTotal.spReporteDetalladoTotalDataTable tabla = new DataSetDetalleTotal.spReporteDetalladoTotalDataTable();
                    ta.Fill(tabla, IdApertura, ListaPisos[index_piso], IdCaja, IdUsuario);
                    reportViewer1.LocalReport.DataSources.Clear();
                    reportViewer1.LocalReport.EnableExternalImages = true;
                    ParametrosReporte("DataSet1", (DataTable)tabla, reporte, reportViewer1);
                    //-------------------

                    DataSetGastos_CierreTableAdapters.Reporte_Gastos_Operativos_CierreTableAdapter ta2 = new DataSetGastos_CierreTableAdapters.Reporte_Gastos_Operativos_CierreTableAdapter();
                    ta2.Connection = new System.Data.SqlClient.SqlConnection(DataSetConexion);

                    DataSetGastos_Cierre.Reporte_Gastos_Operativos_CierreDataTable tabla2 = new DataSetGastos_Cierre.Reporte_Gastos_Operativos_CierreDataTable();
                    ta2.Fill(tabla2, IdApertura, IdCaja, IdUsuario);

                    ParametrosReporte("DataSet2", (DataTable)tabla2, reporte, reportViewer1);
                    //-----------------------------------------------------

                    Dataset.DataSetReporteDetalladoTotal_FormaPagoTableAdapters.spReporteDetalladoTotal_FormaPagoTableAdapter ta3 = new Dataset.DataSetReporteDetalladoTotal_FormaPagoTableAdapters.spReporteDetalladoTotal_FormaPagoTableAdapter();
                    ta3.Connection = new System.Data.SqlClient.SqlConnection(DataSetConexion);

                    Dataset.DataSetReporteDetalladoTotal_FormaPago.spReporteDetalladoTotal_FormaPagoDataTable tabla3 = new Dataset.DataSetReporteDetalladoTotal_FormaPago.spReporteDetalladoTotal_FormaPagoDataTable();
                    ta3.Fill(tabla3, IdApertura, ListaPisos[index_piso], IdCaja, IdUsuario);

                    ParametrosReporte("DataSet3", (DataTable)tabla3, reporte, reportViewer1);
                    //-----------------------------------------------------------------------


                    Dataset.DataSetReporteResumenVendedor_CierreCajaTableAdapters.spReporteResumenVendedor_CierreCajaTableAdapter ta4 = new Dataset.DataSetReporteResumenVendedor_CierreCajaTableAdapters.spReporteResumenVendedor_CierreCajaTableAdapter();
                    ta4.Connection = new System.Data.SqlClient.SqlConnection(DataSetConexion);

                    Dataset.DataSetReporteResumenVendedor_CierreCaja.spReporteResumenVendedor_CierreCajaDataTable tabla4 = new Dataset.DataSetReporteResumenVendedor_CierreCaja.spReporteResumenVendedor_CierreCajaDataTable();
                    ta4.Fill(tabla4, IdApertura, ListaPisos[index_piso], IdCaja, IdUsuario);

                    ParametrosReporte("DataSet4", (DataTable)tabla4, reporte, reportViewer1);

                    //-----------------------------------------------------------------------

                    Dataset.DataSetReporteResumenProductos_CierreCajaTableAdapters.spReporteResumenProductos_CierreCajaTableAdapter ta5 = new Dataset.DataSetReporteResumenProductos_CierreCajaTableAdapters.spReporteResumenProductos_CierreCajaTableAdapter();
                    ta5.Connection = new System.Data.SqlClient.SqlConnection(DataSetConexion);

                    Dataset.DataSetReporteResumenProductos_CierreCaja.spReporteResumenProductos_CierreCajaDataTable tabla5 = new Dataset.DataSetReporteResumenProductos_CierreCaja.spReporteResumenProductos_CierreCajaDataTable();
                    ta5.Fill(tabla5, IdApertura, ListaPisos[index_piso], IdCaja, IdUsuario);

                    ParametrosReporte("DataSet5", (DataTable)tabla5, reporte, reportViewer1);



                    this.reportViewer1.RefreshReport();


                    //----------------------------------
                }
                
            }
            catch (Exception e) {
                MessageBox.Show($"error al crear el informe=>\n{e.Message}");
            }
        }
        void Imprimir()
        {
            try
            {
                ListaPisos.Add(0);
                int pisos = ListaPisos.Count;

                if (ListaPisos.Count <= 2)
                {

                    pisos = 1;
                }


                for (int i = 0; i < pisos; i++)
                {
                    AsignarRutaReporte();



                    DataTable datos = new DataTable();
                    int index_piso = ListaPisos.ToArray().Length;
                    index_piso--;
                    if (pisos == 1)
                        datos = N_Venta1.ResumenVentasProductosDetalladoTotal(IdApertura, ListaPisos[index_piso], IdCaja, IdUsuario);
                    else datos = N_Venta1.ResumenVentasProductosDetalladoTotal(IdApertura, ListaPisos[i], IdCaja, IdUsuario);


                    reportViewer1.LocalReport.DataSources.Clear();

                    ReportDataSource dataSource = new ReportDataSource("DataSet1", datos);
                     
                    RutaQr = "";
                    LocalReport relatorio = new LocalReport();
                    string reporte = RutaReportes;                   
                    reporte += "2020\\Caja\\";
                    reporte += "reporteDetalladoTotal.rdlc";
                    relatorio.ReportPath = reporte;
                    ImpresoranNow = ImpresoraCaja;
                    relatorio.DataSources.Add(dataSource);
                    string PARA = "Para";
                    ReportParameter[] parameters = new ReportParameter[11];
                    parameters[0] = new ReportParameter(PARA + "QR", @"file:////" + RutaQr, true);
                    parameters[1] = new ReportParameter(PARA + "RAZON", Razon, true);
                    parameters[2] = new ReportParameter(PARA + "NOMBRECOM", Nombrecom, true);
                    parameters[3] = new ReportParameter(PARA + "RUC", RucEmpresa, true);
                    parameters[4] = new ReportParameter(PARA + "TELEFONO", Telefono, true);
                    parameters[5] = new ReportParameter(PARA + "DIRECCION", Direccion, true);
                    parameters[6] = new ReportParameter(PARA + "WEB", Web, true);
                    parameters[7] = new ReportParameter(PARA + "EMAIL", Email, true);
                    parameters[8] = new ReportParameter(PARA + "LOGO", @"file:////" + RutaLogo, true);
                    parameters[9] = new ReportParameter(PARA + "CIUDAD", Ciudad, true);
                    parameters[10] = new ReportParameter(PARA + "DISTRITO", Distrito, true);
                    relatorio.EnableExternalImages = true;
                    relatorio.SetParameters(parameters);
                    //aaqui entra la segunda consulta - para gastos operativos


                    DataTable datos_gastos = new DataTable();
                    datos_gastos = N_Venta1.Reporte_Gastos_Operativos_Cierre(IdApertura, IdCaja, IdUsuario);

                    ReportDataSource dataSource2 = new ReportDataSource("DataSet2", datos_gastos);
                    dataSource2.Name = "DataSet2";
                    relatorio.DataSources.Add(dataSource2);



                    Exportar(relatorio);
                    Imprimirr(relatorio);
                }

            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
            finally
            {

            }
        }
        void Pisos()
        {
            ListaPisos.Clear();
            foreach (DataRow r in Config.MostrarRestaurantes().Rows)
            {
                SeleccionRow = r;
                ListaPisos.Add(Valor(1, "int", true));
            }
        }
        static List<int> ListaPisos = new List<int>();
    }
}
