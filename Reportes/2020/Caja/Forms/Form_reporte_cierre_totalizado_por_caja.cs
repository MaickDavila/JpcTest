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
    public partial class Form_reporte_cierre_totalizado_por_caja : Imprimir
    {
        public DateTime FechaIni { get; set; }
        public DateTime FechaFin { get; set; }

        public Form_reporte_cierre_totalizado_por_caja()
        {
            InitializeComponent();
        }

        private void Form_reporte_cierre_totalizado_por_caja_Load(object sender, EventArgs e)
        {
            Imprimir();
            Close();
        }

        void Imprimir()
        {
            try
            {

                AsignarRutaReporte();



                DataTable datos = new DataTable();

                datos = N_Apertura.sp_reporte_cierre_denominaciones_por_fecha(FechaIni, FechaFin);


                reportViewer1.LocalReport.DataSources.Clear();

                ReportDataSource dataSource = new ReportDataSource("DataSet1", datos);

                RutaQr = "";
                LocalReport relatorio = new LocalReport();
                string reporte = RutaReportes;
                reporte += "2020\\Caja\\";
                reporte += "reporteCierreTotalizadoPorCajas.rdlc";
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


                DataTable datos2 = new DataTable();
                datos2 = N_Apertura.sp_reporte_cierre_suma_denominaciones_por_usuairo(FechaIni, FechaFin);

                ReportDataSource dataSource2 = new ReportDataSource("DataSet2", datos2);
                dataSource2.Name = "DataSet2";
                relatorio.DataSources.Add(dataSource2);



                Exportar(relatorio);
                Imprimirr(relatorio);

            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
            finally
            {

            }
        }
    }
}
