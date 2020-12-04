using Microsoft.Reporting.WinForms;
using Presentacion.Reportes._2020.Ventas.Restaurant.dataset;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Runtime.Remoting.Messaging;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Presentacion.Reportes._2020.Ventas.Restaurant.forms
{
    public partial class ticket_delivery : Imprimir
    {
        public long IdVenta { get; set; }
        public ticket_delivery()
        {
            InitializeComponent();
        }

        private void ticket_delivery_Load(object sender, EventArgs e)
        {
            Imprimir();
            Close();
        }
        void Imprimir()
        {
            try
            {
                var config = ConfigJson.Tickets.Find(item => item.Tag == "restaurant");
                var configDelivery = config.Items.Find(item => item.Name == "delivery");

                if (!configDelivery.State)
                {
                    MessageBox.Show("La función de imprimir el ticket de delivery está desactivada!", Sistema, MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                } 

                DataTable tabla = N_Venta1.sp_reporte_delivery(IdVenta);

                ReportDataSource dataSource = new ReportDataSource("DataSet1", tabla);

                LocalReport relatorio = new LocalReport();
                relatorio.ReportPath = RutaReportes + "2020//Ventas//Restaurant//ticket_delivery.rdlc";
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

                foreach (var item in configDelivery.Printers)
                {

                   
                    relatorio.ReportPath = RutaReportes + item.ReportName;
                    ImpresoranNow = item.PrinterName;
                    ObiarCopias = true;

                    while (true)
                    {
                        if (ImpresoraDisponible(ImpresoranNow))
                        {
                            Imprimirr(relatorio);
                            break;
                        }
                    }                    
                }
                relatorio.Dispose();
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }
    }
}
