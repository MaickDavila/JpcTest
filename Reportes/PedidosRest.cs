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
    public partial class PedidosRest : Imprimir
    {
        int IdMesa = 0;
        int NumeroGrupos;
        List<string> NombreGrupos = new List<string>();
        List<int> IdsGrupos = new List<int>();
        int IdGrupo;
        public PedidosRest()
        {
            InitializeComponent();
        }
        public PedidosRest(int id)
        {
            InitializeComponent();
            IdMesa = id;
        }
        private void PedidosRest_Load(object sender, EventArgs e)
        {
            Imprmir2();
            Close();
        }                
        
        string DevolVerNombreImpresora(string nombregrupo)
        {
            string salida = "";
            foreach (string s in ImpresorasNameEleccion_Rest())
            {
                Campos = s.Split('|');
                if (Campos[0].Trim().ToUpper().Equals(nombregrupo.Trim().ToUpper())) 
                {
                    salida = Campos[1];
                    break;
                }               
            }
            return salida;
        }
        string DevolverNombreReporte(string nombreimpresora)
        {
            string salida = "";
            foreach (string s in ImpresorasNameEleccion_Rest())
            {
                Campos = s.Split('|');
                if (nombreimpresora.Equals(Campos[1]))
                {
                    salida = Campos[2];
                    break;
                }
            }
            return salida;
        }
        int CantidadImpresoras()
        {
            Impresorass.Clear();
            int salida = 1, cont = 0;
            Impresorass.Add("0");
            foreach (string s in ImpresorasNameEleccion_Rest())
            {
                Campos = s.Split('|');
                string nombreaux = Campos[1];
                if (cont == 0)
                    Impresorass.Add(nombreaux);
                else
                {
                    bool hay = false;
                    foreach (string ss in Impresorass)
                    {
                        if (nombreaux == ss)
                            hay = true;
                    }
                    if (!hay)
                        Impresorass.Add(nombreaux);
                }
                cont++;
            }
            return salida = Impresorass.Count - 1;
        }
        List<string> Impresorass = new List<string>();
        void Imprmir2()
        {                    
            try
            {               
                DataTable maqueta2 = new DataTable();
                maqueta2.Columns.Add("Id");
                maqueta2.Columns.Add("IdPedido");
                maqueta2.Columns.Add("IdMesa");
                maqueta2.Columns.Add("IdProducto");
                maqueta2.Columns.Add("Descripcion");
                maqueta2.Columns.Add("CodigoBarra");
                maqueta2.Columns.Add("UMedida");
                maqueta2.Columns.Add("Cantidad");
                maqueta2.Columns.Add("Precio");
                maqueta2.Columns.Add("Subtotal");
                maqueta2.Columns.Add("igv");
                maqueta2.Columns.Add("Descuento");
                maqueta2.Columns.Add("total");
                maqueta2.Columns.Add("Pagado");
                maqueta2.Columns.Add("Eliminado");
                maqueta2.Columns.Add("Factor");
                maqueta2.Columns.Add("IdUnidad");
                maqueta2.Columns.Add("IdPiso");
                maqueta2.Columns.Add("IdUsuario");
                maqueta2.Columns.Add("NumSecuencia");
                maqueta2.Columns.Add("Grupo");
                maqueta2.Columns.Add("IdGrupo");
                maqueta2.Columns.Add("Mesa");
                maqueta2.Columns.Add("Mozo");
                maqueta2.Columns.Add("Descripcion_Grupo");

                List<DataTable> Tables = new List<DataTable>();
                Tables.Add(maqueta2);
                int cantidadImpresoras = CantidadImpresoras();
                int contTable = 0;
                List<string> impressaux = new List<string>();
                impressaux.Add("0");

                DataTable FormatoRest = N_Venta1.FormatoRest(IdMesa, IdPiso);



                for (int i = 1; i <= cantidadImpresoras; i++) 
                {
                    DataTable maqueta = new DataTable();
                    maqueta.TableName = "tbl_" + contTable;
                    MeterColumnas(maqueta2, maqueta);

                    
                    foreach (DataRow r in FormatoRest.Rows) 
                    {                                              
                        string grupoconsulta = r["grupo"].ToString();
                        string impres = DevolVerNombreImpresora(grupoconsulta).Trim().ToUpper();
                        string nombreim = Impresorass[i].Trim().ToUpper();
                        if (nombreim.Equals(impres)) 
                        {
                            SeleccionRow = r;
                            string cantidad, precio, subtotal, igv, descuento, total;
                            cantidad = Math.Round(double.Parse(r["cantidad"].ToString()), 0).ToString();
                            precio = Math.Round(double.Parse(r["precio"].ToString()), 2).ToString();
                            subtotal = Math.Round(double.Parse(r["subtotal"].ToString()), 2).ToString();
                            igv = Math.Round(double.Parse(r["igv"].ToString()), 2).ToString();
                            descuento = Math.Round(double.Parse(r["descuento"].ToString()), 2).ToString();
                            total = Formato(r["total"].ToString());
                            string secunecua = r["NumSecuencia"].ToString();

                            maqueta.Rows.Add(Valor(0, true), Valor(1, true), Valor(2, true), Valor(3, true), Valor(4, true), Valor(5, true),
                                Valor(6, true), cantidad, precio, subtotal, igv, descuento,
                                total, Valor(13, true), Valor(14, true), Valor(15, true), Valor(16, true), Valor(17, true), Valor(18, true), Valor(19, true), Valor(20, true), Valor(21, true), Valor(22, true), Valor(23, true), Valor(24, true));
                        }
                    }
                    if (maqueta.Rows.Count != 0)
                    {
                        Tables.Add(maqueta);
                        impressaux.Add(Impresorass[i]);
                    }                    
                    contTable++;
                }
                int contaux = 0;
                do
                {
                    for (int i = 1; i < Tables.Count; i++)
                    {
                        if (contaux == 0)
                            ImpresoranNow = impressaux[i];
                        else
                            ImpresoranNow = NombreImpresoraTikesito;

                        reportViewer1.LocalReport.DataSources.Clear();

                        ReportDataSource dataSource = new ReportDataSource("DataSet1", Tables[i]);
                        RutaQr = "";
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
                        Imprimirr(relatorio);
                    }
                    contaux++;

                } while (Tikesito && contaux <= 1 && IdMesa >= 500);

            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
            finally
            {
                Mensaje = N_Venta1.ResetarTemp(IdMesa, IdPiso);
                //if (Mensaje == null)
                //    MessageBox.Show("EL TICKET NO SE ELIMINÓ, PORFAVOR CONTACTESE: " + "\n- JORGE PUGA DE LA CRUZ, TELF. 970637964." + "\nMAICK DÁVILA JESÚS, TELF. 970637964", Sistema + "- Puede que se vuelva a imprimir el ticker al cobrar el pedido", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }
        void MeterColumnas(DataTable entrada, DataTable salida)
        {
            foreach (DataColumn c in entrada.Columns)
            {
                salida.Columns.Add(c.ColumnName);
            }
        }      
        private void reportViewer1_Load(object sender, EventArgs e)
        {

        }
    }
}
