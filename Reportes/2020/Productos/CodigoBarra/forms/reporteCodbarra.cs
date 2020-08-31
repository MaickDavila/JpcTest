using Presentacion.Reportes._2020.Productos.CodigoBarra.Dataset;
using Presentacion.Reportes._2020.Productos.CodigoBarra.Dataset.DataSetCodBarraTableAdapters;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Presentacion.Reportes._2020.Productos.CodigoBarra.forms
{
    public partial class reporteCodbarra : Imprimir
    {
        public reporteCodbarra()
        {
            InitializeComponent();
        }

        private void reporteCodbarra_Load(object sender, EventArgs e)
        {

            this.Imprimir();

        }

        void Imprimir()
        {
            try
            {
                spCodigoBarraImpresionTableAdapter ta = new spCodigoBarraImpresionTableAdapter();
                ta.Connection = new System.Data.SqlClient.SqlConnection(DataSetConexion);
                DataSetCodBarra.spCodigoBarraImpresionDataTable tabla = new DataSetCodBarra.spCodigoBarraImpresionDataTable();
                ta.Fill(tabla);
                ParametrosReporte("DataSet1", (DataTable)tabla, "2020\\Productos\\CodigoBarraImpresion.rdlc", reportViewer1);

            }
            catch (Exception e)
            {

                throw e;
            }
        }
    }
}
