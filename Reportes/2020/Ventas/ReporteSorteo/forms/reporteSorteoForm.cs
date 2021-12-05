using Microsoft.Reporting.WinForms;

using Presentacion.Inicio;

using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Windows.Forms;

namespace Presentacion.Reportes._2020.Ventas.ReporteSorteo.forms
{
    public partial class reporteSorteoForm : Imprimir
    {
        public long IdVenta { get; set; }
        public reporteSorteoForm()
        {
            InitializeComponent();
        }

        private void reporteSorteoForm_Load(object sender, EventArgs e)
        {
            Imprimir();             
        }

        void LLenar()
        {
            try
            {
                string BolFac = "";

                foreach (DataRow r in N_Venta1.BuscarVentasId(IdVenta).Rows)
                {
                    SeleccionRow = r;
                    BolFac = Valor("IdDocumento", true);
                    NumeroFac = Valor("SerieDoc", true) + "-" + Valor("NumeroDoc", true);
                    break;
                }
                
                RutaQr = RutaFacturador + @"CODIGOBARRA\" + RucEmpresa + "-" + BolFac + "-" + NumeroFac + ".Bmp";
                RutaLogo = RutaFacturador + @"LOGO\logoempresa.jpg";
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "IMPRESION COMPROBANTE - LLENAR DATOS");
            }
        }

        public void Imprimir()
        {
            try
            {
                AsignarImpresoras();
                LLenar();
                int count = N_Venta1.BuscarVentasDetalleId(IdVenta, false).Rows.Count;                 

                DataTable tabla = N_Venta1.ReporteComprobante(IdVenta, false);                                 
                ReportDataSource dataSource = new ReportDataSource("DataSet1", tabla);
                dataSource.Name = "DataSet1";                 

                LocalReport relatorio = new LocalReport();
                ReporteNow = "default.rdcl";
                relatorio.DataSources.Add(dataSource);                
                string PARA = "Para";
                ReportParameter[] parameters = new ReportParameter[11];
                parameters[0] = new ReportParameter(PARA + "QR", @"file:////" + RutaQr, true);
                parameters[1] = new ReportParameter(PARA + "RAZON", VariablesGlobales.ConfiguracionGeneral.RazonSocial, true);
                parameters[2] = new ReportParameter(PARA + "NOMBRECOM", VariablesGlobales.ConfiguracionGeneral.NombreComercial, true);
                parameters[3] = new ReportParameter(PARA + "RUC", VariablesGlobales.ConfiguracionGeneral.Ruc, true);
                parameters[4] = new ReportParameter(PARA + "TELEFONO", VariablesGlobales.ConfiguracionGeneral.Telefono, true);
                parameters[5] = new ReportParameter(PARA + "DIRECCION", VariablesGlobales.ConfiguracionGeneral.Direccion, true);
                parameters[6] = new ReportParameter(PARA + "WEB", VariablesGlobales.ConfiguracionGeneral.Web, true);
                parameters[7] = new ReportParameter(PARA + "EMAIL", VariablesGlobales.ConfiguracionGeneral.Correo, true);
                parameters[8] = new ReportParameter(PARA + "LOGO", @"file:////" + RutaLogo, true);
                parameters[9] = new ReportParameter(PARA + "CIUDAD", VariablesGlobales.ConfiguracionGeneral.Ciudad, true);
                parameters[10] = new ReportParameter(PARA + "DISTRITO", VariablesGlobales.ConfiguracionGeneral.Distrito, true);
                relatorio.EnableExternalImages = true;


                while (true)
                {
                    if (!ImpresoraDisponible(ImpresoranNow)) continue;

                    //nueva logica con json
                    var pcName = Environment.MachineName.Trim().ToLower();
                    if (ConfigJson.Caja.Pcs.Count <= 0)
                    {
                        MessageBox.Show(@"Aun no tiene ninguna configuración de impresoras con PCs!", Sistema, MessageBoxButtons.OK, MessageBoxIcon.Error);
                        return;
                    }
                    //
                    var pcConfig = ConfigJson.Caja.Pcs.Find(item => item.Nombre.ToLower().ToLower() == pcName && item.Enabled);
                    if (pcConfig == null)
                    {
                        MessageBox.Show($"Ocurrio un problema, aun no configura sus impresoras de caja para esta Pc {pcName}!");
                        return;
                    }
                    
                    List<Impresora> impresorasParametrisadas = null;
                    impresorasParametrisadas = (from row in pcConfig.Impresoras
                                                where row.Limit >= count
                                                orderby row.Limit ascending
                                                select row).ToList();
                    //                        
                    var impresoraSeleccionada = impresorasParametrisadas.Count > 0 ? impresorasParametrisadas[0] : null;
                    if (impresoraSeleccionada == null)
                    {
                        MessageBox.Show(@"Por favor, antes de continuar tendrá que configurar los parámetros de impresion en caja!", Sistema, MessageBoxButtons.OK, MessageBoxIcon.Error);
                        return;
                    }
                    //
                    ImpresoranNow = impresoraSeleccionada.Nombre;
                    ReporteNow = "2020/Ventas/ReporteSorteo/reporteSorteo.rdlc";
                    relatorio.ReportPath = RutaReportes + ReporteNow;
                    //
                    relatorio.SetParameters(parameters);
                    Exportar(relatorio);
                    Imprimirr(relatorio);
                    //                     
                    break;
                }
                relatorio.Dispose();
            }
            catch (Exception ex)
            {
                dynamic message2 = ex.InnerException.InnerException;
                if (message2 != null) message2 = message2.Message;
                else message2 = "";
                MessageBox.Show(ex.Message + "\n" + ex.InnerException.Message + "\n" + message2, "IMPRESION COMPROBANTE SORTEO");
            }
            finally
            {
                
            }
        }
    }
}
