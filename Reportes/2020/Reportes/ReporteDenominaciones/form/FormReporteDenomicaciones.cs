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

namespace Presentacion.Reportes._2020.Reportes.ReporteDenominaciones.form
{
    public partial class FormReporteDenomicaciones : Imprimir
    {
        public int IdUsuarioAux { get; set; }
        public int IdCajaAux { get; set; }
        public int IdAperturaAux { get; set; }


        public FormReporteDenomicaciones()
        {
            InitializeComponent();
        }

        private void FormReporteDenomicaciones_Load(object sender, EventArgs e)
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
                datos = N_Venta1.sp_reporte_denominaciones(IdAperturaAux, IdCajaAux, IdUsuarioAux);

                reportViewer1.LocalReport.DataSources.Clear();

                ReportDataSource dataSource = new ReportDataSource("DataSet1", datos);

                RutaQr = "";
                LocalReport relatorio = new LocalReport();
                string reporte = RutaReportes;
                reporte += "2020\\Reportes\\ReporteDenominaciones\\";
                reporte += "ReporteDenominaciones.rdlc";
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
                datos_gastos = N_Venta1.Reporte_Gastos_Operativos_Cierre(IdAperturaAux, IdCajaAux, IdUsuarioAux);

                ReportDataSource dataSource2 = new ReportDataSource("DataSet2", datos_gastos);
                dataSource2.Name = "DataSet2";
                relatorio.DataSources.Add(dataSource2);



                Exportar(relatorio);
                Imprimirr(relatorio);
            }
            catch (Exception e)
            {
                MessageBox.Show("Erro al imprimir las denomicaciones!" + e.Message);
            }
        }
    }
}
