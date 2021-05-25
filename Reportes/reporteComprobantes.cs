using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;
using Microsoft.Reporting.WinForms;

namespace Presentacion.Reportes
{
    public partial class reporteComprobantes : Imprimir
    {         
        bool Imprimir_pdf;         
        private long IdVenta;
        private string NombreCPE;
        private bool Pdf;       

        public reporteComprobantes(long idventa)
        {
            //InitializeComponent();
            IdVenta = idventa;
            this.Load += new EventHandler(reporteComprobantes_Load);
        }
        public reporteComprobantes(long idventa, bool pdf, string nombrearchivo)
        {
            //InitializeComponent();
            IdVenta = idventa;
            Pdf = pdf;
            NombreCPE = nombrearchivo;
            this.Load += new EventHandler(reporteComprobantes_Load);
        }
        public reporteComprobantes(long idventa, bool pdf, string nombrearchivo, bool imprimir_pdf)
        {
            //InitializeComponent();
            IdVenta = idventa;
            Pdf = pdf;
            NombreCPE = nombrearchivo;
            Imprimir_pdf = imprimir_pdf;
            this.Load += new EventHandler(reporteComprobantes_Load);
        }
        public reporteComprobantes()
        {
            InitializeComponent();
            this.Load += new EventHandler(reporteComprobantes_Load);
        }

        private void reporteComprobantes_Load(object sender, EventArgs e)
        {
            
            if (!Pdf) Imprimir();
            else GENERARPDF_();
            Close();
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
                //MessageBox.Show($"despues de LLenar");
                
                NombreCPE = RucEmpresa + "-" + BolFac + "-" + NumeroFac;
                RutaQr = RutaFacturador + @"CODIGOBARRA\" + RucEmpresa + "-" + BolFac + "-" + NumeroFac + ".Bmp";
                RutaLogo = RutaFacturador + @"LOGO\logoempresa.jpg";
            }
            catch (Exception ex) { MessageBox.Show(ex.Message,"IMPRESION COMPROBANTE - LLENAR DATOS"); }
        }
        void LLenar_2()
        {
            try
            {                
                RutaQr = RutaFacturador + @"CODIGOBARRA\" + NombreCPE + ".Bmp";
                RutaLogo = RutaFacturador + @"LOGO\logoempresa.jpg";
            }
            catch (Exception ex) { MessageBox.Show(ex.Message, "IMPRESION COMPROBANTE - LLENAR DATOS"); }
        }
        public void GENERARPDF_()
        {
            try
            {                
                AsignarImpresoras();
                //IDVENTA
                DataTable maqueta2 = new DataTable();
                if (Sql)
                {
                    if (!EsIntegracion)
                    {
                        maqueta2 = N_Venta1.ReporteComprobante(IdVenta, true);
                    }
                    else
                    {
                        maqueta2 = N_CPE_SQL.COMPROBANTE(IdVenta);
                    }
                }
                else if (MySql)
                {
                    maqueta2 = N_CPE_MYSQL.COMPROBANTE(IdVenta);
                }
                else if (Acces)
                {
                    maqueta2 = N_CPE_ACCES.COMPROBANTE(IdVenta);
                }

                LLenar_2();
                //reportViewer1.LocalReport.DataSources.Clear();
                ImpresorasNameEleccion(1);

                ReportDataSource dataSource = new ReportDataSource("DataSet1", (DataTable)maqueta2);

                LocalReport relatorio = new LocalReport();
                relatorio.ReportPath = RutaReportes + "Report1_A4-Integracion.rdlc";
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


                while (true)
                {
                    if (ImpresoraDisponible(ImpresoranNow))
                    {

                        if (Imprimir_pdf)
                            Imprimirr(relatorio);
                        else
                        {
                            GenerarPdf(relatorio, NombreCPE);
                        }
                        break;
                    }
                }


            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "GENERAR PDF COMPROBANTE", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            finally
            {
                //N_SQLAPI.EstablecerConexionOriginal();
            }
        }
      
        public void Imprimir()
        {            
            try
            {                 
                AsignarImpresoras();
                LLenar();
                int count = N_Venta1.BuscarVentasDetalleId(IdVenta, false).Rows.Count;
                bool esCredito = false;

                DataTable tabla = N_Venta1.ReporteComprobante(IdVenta, EsIntegracion);

                if(tabla.Rows.Count > 0)
                {
                    string aux = tabla.Rows[0]["IdFormaPago"].ToString();
                    int idFormaPago = 0;
                    int.TryParse(aux, out idFormaPago);
                    esCredito = idFormaPago == 2;
                }

                ReportDataSource dataSource = new ReportDataSource("DataSet1", (DataTable)tabla);

                LocalReport relatorio = new LocalReport();
                ReporteNow = "default.rdcl";
                //relatorio.ReportPath = RutaReportes + ReporteNow;
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

                
                while (true)
                {
                    if (ImpresoraDisponible(ImpresoranNow))
                    {
                        //nueva logica con json
                        string pcName = Environment.MachineName.Trim().ToLower();
                        if (ConfigJson.Caja.Pcs.Count <= 0)
                        {
                            MessageBox.Show("Aun no tiene ninguna configuración de impresoras con PCs!", Sistema, MessageBoxButtons.OK, MessageBoxIcon.Error);
                            return;
                        }
                        //
                        var pcConfig = ConfigJson.Caja.Pcs.Find(item => item.Nombre.ToLower().ToLower() == pcName && item.Enabled);
                        if(pcConfig == null)
                        {
                            MessageBox.Show($"Ocurrio un problema, aun no configura sus impresoras de caja para esta Pc {pcName}!");
                            return;
                        }

                        //primero vemos si es credito                        
                        List<Inicio.Impresora> impresorasParametrisadas = null;
                        if (esCredito)
                        {
                            if (pcConfig.CheckCredito.Enabled)
                            {
                                impresorasParametrisadas = (from row in pcConfig.CheckCredito.Impresoras
                                                            where row.Limit >= count
                                                            orderby row.Limit ascending
                                                            select row).ToList();
                            }
                            else
                            {
                                impresorasParametrisadas = (from row in pcConfig.Impresoras
                                                            where row.Limit >= count
                                                            orderby row.Limit ascending
                                                            select row).ToList();
                            }
                        }
                        else
                        {
                            impresorasParametrisadas = (from row in pcConfig.Impresoras
                                                        where row.Limit >= count
                                                        orderby row.Limit ascending
                                                        select row).ToList();
                        }
                        //                        
                        var impresoraSeleccionada = impresorasParametrisadas.Count > 0 ? impresorasParametrisadas[0] : null;
                        if(impresoraSeleccionada == null)
                        {
                            MessageBox.Show("Por favor, antes de continuar tendrá que configurar los parámetros de impresion en caja!", Sistema, MessageBoxButtons.OK, MessageBoxIcon.Error);
                            return;
                        }                        
                        //
                        ImpresoranNow = impresoraSeleccionada.Nombre;
                        ReporteNow = impresoraSeleccionada.Report;
                        relatorio.ReportPath = RutaReportes + ReporteNow;
                        //
                        relatorio.SetParameters(parameters);
                        Exportar(relatorio);
                        Imprimirr(relatorio);
                        //
                        if(pcConfig.CopiasAlmacen.Items.Count > 0 && pcConfig.CopiasAlmacen.Enabled)
                        {
                            pcConfig.CopiasAlmacen.Items.FindAll(item => item.Enabled).ForEach(element => 
                            {
                                ImpresoranNow = element.Nombre;
                                ReporteNow = element.Report;
                                relatorio.ReportPath = RutaReportes + ReporteNow;
                                Exportar(relatorio);
                                Imprimirr(relatorio);
                            });
                        }
                        //esto era del almacen
                        //if (!ImpresorasNameEleccion_Almacen()) break;
                        break;
                    }
                }
                relatorio.Dispose();
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message + "\n" + ex.InnerException.Message, "IMPRESION COMPROBANTE ");
            }
            finally
            {
                GuardarRuta();
            }
        }
        void GuardarRuta()
        {
            try
            {
                Escribir = File.AppendText("log_errores.txt");
                Escribir.WriteLine(NombreCPE);
                Escribir.WriteLine(RutaQr);
                Escribir.WriteLine(RutaLogo);
                Escribir.Close();
            }
            catch (Exception)
            {

            }
        }
        private void reportViewer1_Load(object sender, EventArgs e)
        {

        }

        private void reporteComprobantes_FormClosing(object sender, FormClosingEventArgs e)
        {
                       
        }
    }
}
