using Microsoft.Reporting.WinForms;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace Presentacion.Reportes
{
    public partial class ReportePreCuenta : Imprimir
    {
        int IdPiso, IdMesa;
        public ReportePreCuenta()
        {
            InitializeComponent();
        }
        public ReportePreCuenta(int idpiso, int idmesa)
        {
            InitializeComponent();
            IdPiso = idpiso;
            IdMesa = idmesa;
        }
        private void ReportePreCuenta_Load(object sender, EventArgs e)
        {
            Imprimir();

        }
        void Imprimir()
        {

            try
            {
                AsignarRutaReporte();
                DataSetPreCuentaTableAdapters.spFormatoPreCuentaTableAdapter ta = new DataSetPreCuentaTableAdapters.spFormatoPreCuentaTableAdapter();
                ta.Connection = new System.Data.SqlClient.SqlConnection(DataSetConexion);
                DataSetPreCuenta.spFormatoPreCuentaDataTable tabla = new DataSetPreCuenta.spFormatoPreCuentaDataTable();
                ta.Fill(tabla, IdMesa, IdPiso);

                reportViewer1.LocalReport.DataSources.Clear();

                ReportDataSource dataSource = new ReportDataSource("DataSet1", (DataTable)tabla);
                RutaQr = "";
                LocalReport relatorio = new LocalReport();
                relatorio.ReportPath = RutaReportes + "PreCuenta.rdlc";
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
                Exportar(relatorio);
                Imprimirr(relatorio);
            }
            catch (Exception ex)
            {
                MessageBox.Show("¡Ocurrio un error al iprimir la Pre-Cuenta! " + "\n" + ex.Message, Sistema, MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            finally
            {
                Close();
            }
        }
    }
}
