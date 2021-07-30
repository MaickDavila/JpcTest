using Microsoft.Office.Interop.Excel;
using Microsoft.VisualBasic;
using Presentacion.Reportes._2020.Productos.CodigoBarra.Dataset;
using Presentacion.Reportes._2020.Productos.CodigoBarra.Dataset.DataSetCodBarraTableAdapters;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
 

namespace Presentacion.Reportes._2020.Productos.CodigoBarra.forms
{
    public partial class reporteCodbarra : Imprimir
    {
        public int Id { get; set; }
        public int IdAlmacen { get; set; }

        public reporteCodbarra()
        {
            InitializeComponent();
        }

        public reporteCodbarra( int id, int idalmacen)
        {
            InitializeComponent();
            Id = id;
            IdAlmacen = idalmacen;
        }

        private void reporteCodbarra_Load(object sender, EventArgs e)
        {
            
            this.ImprimirReporte();
        }

        void ImprimirReporte()
        {
            try
            {

                var ta = new spCodigoBarraImpresionTableAdapter() {Connection = new SqlConnection(DataSetConexion)};
                var tabla = new DataSetCodBarra.spCodigoBarraImpresionDataTable();
                ta.Fill(tabla, Id, IdAlmacen);
                ParametrosReporte("DataSet1", tabla, "2020\\Productos\\CodigoBarra\\CodigoBarraImpresion.rdlc", reportViewer1);
                this.reportViewer1.RefreshReport();
            }
            catch (Exception e)
            {
                MessageBox.Show($@"Ocurrio un error al generar el reporte! {e.Message}");
            }
        }


        void ImprimirExcel()
        {
            try
            {
                string descripcion, unidad_medida, codigo_barra, precio;
                descripcion = unidad_medida = codigo_barra = precio = "";

                System.Data.DataTable tabla = N_Producto1.spCodigoBarraImpresion(Id, IdAlmacen);

                foreach (DataRow row in tabla.Rows)
                {
                    descripcion = row["Descripcion"].ToString();
                    unidad_medida = row["U_Medida"].ToString();
                    codigo_barra = row["Cod_Barra"].ToString();
                    precio = row["Precio_Unit"].ToString();
                }



                Microsoft.Office.Interop.Excel.Application objApp;
                _Workbook objBook;


                Workbooks objBooks;
                Sheets objSheets;
                _Worksheet objSheet;
                

                objApp = new Microsoft.Office.Interop.Excel.Application();
                objApp.Workbooks.Open(@"D:\DESAROLLO\JPC\Jpc-Consultings-old\Sistema\Presentacion\bin\Debug\IMPCODB.xls");

                objBooks = objApp.Workbooks;

                objBook = objBooks[1];

                objSheets = objBook.Worksheets;

                objSheet = (Microsoft.Office.Interop.Excel._Worksheet)objSheets.get_Item(1);

                precio = Math.Round(decimal.Parse(precio), 2).ToString();


                objSheet.Range["B1"].Value = $"P.U. S/ {precio}";
                objSheet.Range["B2"].Value = codigo_barra.Trim();
                objSheet.Range["B4"].Value = $"{descripcion.Trim()} ({unidad_medida.Trim()})";
                



                objApp.Visible = true;
                













                //Microsoft.Office.Interop.Excel.Application app = new Microsoft.Office.Interop.Excel.Application();
                ////app.Visible = true;
                //app.Workbooks.Open(@"D:\DESAROLLO\JPC\Jpc-Consultings-old\Sistema\Presentacion\bin\Debug\IMPCODB.xls");
                //Worksheets workSheets = app.Worksheets[1];
                //app.Visible = true;
            }
            catch (Exception e)
            {

                throw e;
            }
            
            
            
        




            //object oExcel;
            //object oBook;
            //object oSheet;
            
            //oExcel = Interaction.CreateObject("Excel.Application");            
            //oBook = oExcel.Workbooks.open("reporte.xsl");
            //oSheet = oBook.Worksheets(1);

            //oSheet.Range("B" + 2).value = "Coca cola";

            //oExcel.Visible = true;

            
            //try
            //{
            //    spCodigoBarraImpresionTableAdapter ta = new spCodigoBarraImpresionTableAdapter();
            //    ta.Connection = new System.Data.SqlClient.SqlConnection(DataSetConexion);
            //    DataSetCodBarra.spCodigoBarraImpresionDataTable tabla = new DataSetCodBarra.spCodigoBarraImpresionDataTable();
            //    ta.Fill(tabla, Id, IdAlmacen);
            //    ParametrosReporte("DataSet1", (System.Data.DataTable)tabla, "2020\\Productos\\CodigoBarra\\CodigoBarraImpresion.rdlc", reportViewer1);

            //}
            //catch (Exception e)
            //{
                
            //    throw e;
            //}
        }
    }
}
