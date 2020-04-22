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
    public partial class ReporteConvenio : Imprimir
    {
        int IdConvenio;
        public ReporteConvenio()
        {
            InitializeComponent();
        }
        public ReporteConvenio(long idconvenio)
        {
            InitializeComponent();
            IdConvenio = int.Parse(idconvenio.ToString());
        }

        private void ReporteConvenio_Load(object sender, EventArgs e)
        {
            Imprimir();
            Close();                
        }
         
        public void Imprimir()
        {
            try
            {
                

                AsignarImpresoras();
                ImpresorasNameEleccion(1);

                DataTable tabla = N_Venta1.FormatoConvenio(IdConvenio);

                ReportDataSource dataSource = new ReportDataSource("DataSet1", (DataTable)tabla);

                LocalReport relatorio = new LocalReport();
                relatorio.ReportPath = RutaReportes + "reporte_concenio_informe.rdlc";
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
                MessageBox.Show(ex.Message, "IMPRESION COMPROBANTE ");
            }
            finally
            {
                
            }
        }
    }
}
