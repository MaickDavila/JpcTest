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
        ReportViewer ReportViewerMaick = new ReportViewer();
        bool Imprimir_pdf;
        bool VistaPrevia;
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
                int cont = 0;
                
                AsignarImpresoras();


                LLenar();



                //SistemaDataSetTableAdapters.spReporteComprobanteTableAdapter ta = new SistemaDataSetTableAdapters.spReporteComprobanteTableAdapter();//aqui se lentea cuando es factura

                //SistemaDataSet.spReporteComprobanteDataTable tabla = new SistemaDataSet.spReporteComprobanteDataTable();

                //ta.Connection = N_SQLAPI.ConexionGlobal();

                //ta.Fill(tabla, IdVenta, EsIntegracion);
                int count = N_Venta1.BuscarVentasDetalleId(IdVenta, false).Rows.Count;


                if (!ImpresorasNameEleccion(count))
                {
                    MessageBox.Show("Desea Imprimir de todas formas?, puede que se genere un archivo en pdf.");
                }

                //reportViewer1.LocalReport.DataSources.Clear();

                DataTable tabla = N_Venta1.ReporteComprobante(IdVenta, EsIntegracion);

                ReportDataSource dataSource = new ReportDataSource("DataSet1", (DataTable)tabla);

                LocalReport relatorio = new LocalReport();
                relatorio.ReportPath = RutaReportes + ReporteNow;
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
                        Imprimirr(relatorio);
                        if (ImpresorasNameEleccion_Almacen())
                        {
                            cont++;
                        }
                        else break;

                        break;
                    }
                }
                relatorio.Dispose();


                //do
                //{
                //    LLenar();



                //    //SistemaDataSetTableAdapters.spReporteComprobanteTableAdapter ta = new SistemaDataSetTableAdapters.spReporteComprobanteTableAdapter();//aqui se lentea cuando es factura

                //    //SistemaDataSet.spReporteComprobanteDataTable tabla = new SistemaDataSet.spReporteComprobanteDataTable();

                //    //ta.Connection = N_SQLAPI.ConexionGlobal();

                //    //ta.Fill(tabla, IdVenta, EsIntegracion);
                //    int count = N_Venta1.BuscarVentasDetalleId(IdVenta, false).Rows.Count;
                    
                    
                //    if (!ImpresorasNameEleccion(count)) 
                //    {
                //        MessageBox.Show("Desea Imprimir de todas formas?, puede que se genere un archivo en pdf.");
                //    }

                //    //reportViewer1.LocalReport.DataSources.Clear();

                //    DataTable tabla = N_Venta1.ReporteComprobante(IdVenta, EsIntegracion);

                //    ReportDataSource dataSource = new ReportDataSource("DataSet1", (DataTable)tabla);

                //    LocalReport relatorio = new LocalReport();
                //    relatorio.ReportPath = RutaReportes + ReporteNow;
                //    relatorio.DataSources.Add(dataSource);
                //    string PARA = "Para";
                //    ReportParameter[] parameters = new ReportParameter[11];
                //    parameters[0] = new ReportParameter(PARA + "QR", @"file:////" + RutaQr, true);
                //    parameters[1] = new ReportParameter(PARA + "RAZON", Razon, true);
                //    parameters[2] = new ReportParameter(PARA + "NOMBRECOM", Nombrecom, true);
                //    parameters[3] = new ReportParameter(PARA + "RUC", RucEmpresa, true);
                //    parameters[4] = new ReportParameter(PARA + "TELEFONO", Telefono, true);
                //    parameters[5] = new ReportParameter(PARA + "DIRECCION", Direccion, true);
                //    parameters[6] = new ReportParameter(PARA + "WEB", Web, true);
                //    parameters[7] = new ReportParameter(PARA + "EMAIL", Email, true);
                //    parameters[8] = new ReportParameter(PARA + "LOGO", @"file:////" + RutaLogo, true);
                //    parameters[9] = new ReportParameter(PARA + "CIUDAD", Ciudad, true);
                //    parameters[10] = new ReportParameter(PARA + "DISTRITO", Distrito, true);
                //    relatorio.EnableExternalImages = true;
                    
                //    relatorio.SetParameters(parameters);
                    
                //    Exportar(relatorio);



                //    while (true)
                //    {
                //        if (ImpresoraDisponible(ImpresoranNow))
                //        {
                //            Imprimirr(relatorio);
                //            if (ImpresorasNameEleccion_Almacen())
                //            {
                //                cont++;
                //            }
                //            else break;

                //            break;
                //        }
                //    }

                //} while (cont <= 1);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "IMPRESION COMPROBANTE ");
            }
            finally
            {
                GuardarRuta();
                //N_SQLAPI.EstablecerConexionOriginal();
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
