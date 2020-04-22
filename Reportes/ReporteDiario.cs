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

namespace Presentacion.Reportes
{
    public partial class ReporteDiario : Imprimir
    {
        int IdApertura = 0;

        bool Detallado = false;
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
                Pisos();
                Imprimir();
                if (X)
                    new ReportX(IdApertura).ShowDialog();
                Close();
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
            finally
            {
                N_Venta1.LimpiarPedidos();
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
                        datos = N_Venta1.ResumenVentasProductos(IdApertura, ListaPisos[index_piso], IdCaja, IdUsuario, Detallado);
                    else datos = N_Venta1.ResumenVentasProductos(IdApertura, ListaPisos[i], IdCaja, IdUsuario, Detallado);


                    reportViewer1.LocalReport.DataSources.Clear();

                    ReportDataSource dataSource = new ReportDataSource("DataSet1", datos);
                    RutaQr = "";
                    LocalReport relatorio = new LocalReport();
                    string reporte = RutaReportes;
                    Campos = NombreReporteDiario.Split('.');
                    string nombre_reporte_temp = Campos[0];
                    reporte += nombre_reporte_temp;
                    reporte += Detallado ? "_Detalle.rdlc" : ".rdlc";
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


                    //DataTable datos_gastos = new DataTable();
                    //datos_gastos = N_Venta1.Reporte_Gastos_Operativos_Cierre(IdApertura, IdCaja, IdUsuario);

                    //ReportDataSource dataSource2 = new ReportDataSource("DataSet2", datos_gastos);
                    //relatorio.DataSources.Add(dataSource);



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
