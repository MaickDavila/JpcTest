using Presentacion.DataSetXTableAdapters;
using Presentacion.Reportes._2020.Inventario.Dataset;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Presentacion.Reportes._2020.Inventario.forms
{
    public partial class reporteSaldo : Imprimir
    {
        DateTime Fecha = new DateTime();
        int Almacen = 0;
        public reporteSaldo()
        {
            InitializeComponent();
        }

        public reporteSaldo(DateTime fecha , int almacen)
        {
            InitializeComponent();
            Fecha = fecha;
            Almacen = almacen;
        }

        private void reporteSaldo_Load(object sender, EventArgs e)
        {
            Imprimir();
        }
        void Imprimir()
        {
            try
            {
                Dataset.DataSetSaldoTableAdapters.spAlmacenSaldoTableAdapter ta2 = new Dataset.DataSetSaldoTableAdapters.spAlmacenSaldoTableAdapter(); 
                ta2.Connection = new System.Data.SqlClient.SqlConnection(DataSetConexion);

                DataSetSaldo.spAlmacenSaldoDataTable tabla = new DataSetSaldo.spAlmacenSaldoDataTable();
                
                ta2.Fill(tabla, Almacen, Fecha);



                ParametrosReporte("DataSet1", (DataTable)tabla, "2020\\Inventario\\reporteSaldo.rdlc", reportViewer1, Fecha.ToShortDateString());

            }
            catch (Exception e)
            {

                throw e;
            }
        }
    }
}
