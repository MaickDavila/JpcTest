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
    public partial class ReportX : Imprimir
    {
        int IdApertura;
        public ReportX()
        {
            InitializeComponent();
        }
        public ReportX(int idapertura)
        {
            InitializeComponent();
            IdApertura = idapertura;
        }

        private void ReportX_Load(object sender, EventArgs e)
        {
            getPisos();
            Imprimir();
            Close();
            //this.reportViewer1.RefreshReport();
        }
        void Imprimir()
        {
            try
            {
                
                string splitear = NombreReporteDiario.Split('.')[0];
                splitear += "XX.rdlc";
                splitear = splitear.Trim();
                int pisos = ListaPisos.Count;

                if (ListaPisos.Count <= 2)
                {

                    pisos = 1;
                }
                else ListaPisos.Add(0);

                for (int i = 0; i < pisos; i++)
                {
                    AsignarRutaReporte();

                    DataSetXTableAdapters.sp_ReporteTopSecretTableAdapter ta = new DataSetXTableAdapters.sp_ReporteTopSecretTableAdapter();                    
                    ta.Connection = new System.Data.SqlClient.SqlConnection(DataSetConexion);
                    DataSetX.sp_ReporteTopSecretDataTable tabla = new DataSetX.sp_ReporteTopSecretDataTable();
                    int valor = 0;
                    if (pisos == 1) valor = ListaPisos[ListaPisos.ToArray().Length - 1];
                    else valor = ListaPisos[i];
                    ta.Fill(tabla, valor, IdApertura);
                    //ta.Fill(tabla, ListaPisos[i], IdApertura);

                    reportViewer1.LocalReport.DataSources.Clear();

                    ReportDataSource dataSource = new ReportDataSource("DataSet1", (DataTable)tabla);
                    RutaQr = "";
                    LocalReport relatorio = new LocalReport();
                    relatorio.ReportPath = RutaReportes + splitear;
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
                    ObiarCopias = true;
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
