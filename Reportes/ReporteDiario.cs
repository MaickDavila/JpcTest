using Microsoft.Reporting.WinForms;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Presentacion.Reportes
{
    public partial class ReporteDiario : Imprimir
    {
        public int IdAperturaAux { get; set; }
        public int IdCajaAux { get; set; }
        public int IdUsuarioAux { get; set; }        

        public bool Detallado { get; set; }
        public ReporteDiario()
        {
            InitializeComponent();
        }
        public ReporteDiario(int idapertura, bool detallado)
        {
            InitializeComponent();
            IdApertura = idapertura;
            Detallado = detallado;
        }

        private void ReporteDiario_Load(object sender, EventArgs e)
        {
            try
            {
                getPisos();
                Imprimir();
                if (X)
                    new ReportX(IdAperturaAux).ShowDialog();
                Close();
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
            finally
            {
                
            }
        }
        
        void Imprimir()
        {
            try
            {                
                int pisos = ListaPisos.Count;

                ListaPisos.Add(0);

                for (int i = 0; i <= pisos; i++) 
                {
                    AsignarRutaReporte();
  


                    DataTable datos = new DataTable();
                    //int index_piso = ListaPisos.ToArray().Length;
                    //index_piso--;
                    //if (pisos == 1) 
                    //    datos = N_Venta1.ResumenVentasProductos(IdAperturaAux, ListaPisos[index_piso], IdCajaAux, IdUsuarioAux, Detallado);
                    //else datos = N_Venta1.ResumenVentasProductos(IdAperturaAux, ListaPisos[i], IdCajaAux, IdUsuarioAux, Detallado);
                    datos = N_Venta1.ResumenVentasProductos(IdAperturaAux, ListaPisos[i], IdCajaAux, IdUsuarioAux, Detallado);

                    if (datos.Rows.Count == 0)
                    {
                        string msj = "";
                        msj = ListaPisos[i] == 0 ? "Todos" : ListaPisos[i].ToString();
                        MessageBox.Show($"No tiene datos en el piso {msj}");
                        continue;
                    }

                    reportViewer1.LocalReport.DataSources.Clear();
                    LocalReport relatorio = new LocalReport();


                    ReportDataSource dataSource = new ReportDataSource("DataSet1", datos);
                    RutaQr = "";
                   
                    string reporte = RutaReportes;
                    Campos = NombreReporteDiario.Split('.');
                    string nombre_reporte_temp = Campos[0];
                    reporte += nombre_reporte_temp;
                    reporte += Detallado ? "_Detalle.rdlc" : ".rdlc";
                    relatorio.ReportPath = reporte;
                    ImpresoranNow = ImpresoraCaja;
                    relatorio.DataSources.Add(dataSource);
                    //


                    //SEGUNDO DATASET
                    _2020.Apertura.Dataset.ReporteAperturaDataSetTableAdapters.sp_mostrar_aperturasTableAdapter ta = new _2020.Apertura.Dataset.ReporteAperturaDataSetTableAdapters.sp_mostrar_aperturasTableAdapter();
                    ta.Connection = new System.Data.SqlClient.SqlConnection(DataSetConexion);

                    Reportes._2020.Apertura.Dataset.ReporteAperturaDataSet.sp_mostrar_aperturasDataTable tabla = new _2020.Apertura.Dataset.ReporteAperturaDataSet.sp_mostrar_aperturasDataTable();
                    ta.Fill(tabla, IdAperturaAux, IdUsuarioAux, IdCajaAux);

                    ReportDataSource dataSource2 = new ReportDataSource("DataSet2", (DataTable)tabla);                                         
                    relatorio.DataSources.Add(dataSource2);







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
                    //
                    ObiarCopias = true;

                    while (true)
                    {
                        if (ImpresoraDisponible(ImpresoranNow))
                        {
                            Exportar(relatorio);
                            Imprimirr(relatorio);
                            break;
                        }                       
                    }
                    relatorio.Dispose();
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
        void getPisos()
        {          
            ListaPisos.Clear();
            
            foreach (DataRow r in Config.MostrarRestaurantes().Rows)
            {
                SeleccionRow = r;
                int piso = Valor(1, "int", true);
                var exist = Pisos.Find(item => item == piso.ToString());
                if (exist != null)
                {
                    ListaPisos.Add(piso);
                }
            }
        }
        static List<int> ListaPisos = new List<int>();
    }
}
