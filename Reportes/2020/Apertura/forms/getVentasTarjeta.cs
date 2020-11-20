using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Presentacion.Reportes._2020.Apertura.forms
{
    public partial class getVentasTarjeta : Imprimir
    {
        public int IdAperturaAux { get; set; }
        public int IdCajaAux { get; set; }
        public int IdUsuarioAux { get; set; }

        public getVentasTarjeta()
        {
            InitializeComponent();
        }

        private void getVentasTarjeta_Load(object sender, EventArgs e)
        {
            Imprimir();
        }

        void Imprimir()
        {
            try
            {
                LLenar_2();

                Apertura.Dataset.getVentasTarjetasTableAdapters.sp_get_ventas_tarjetasTableAdapter ta = new Dataset.getVentasTarjetasTableAdapters.sp_get_ventas_tarjetasTableAdapter();
                ta.Connection = new System.Data.SqlClient.SqlConnection(DataSetConexion);

                Apertura.Dataset.getVentasTarjetas.sp_get_ventas_tarjetasDataTable tabla = new Dataset.getVentasTarjetas.sp_get_ventas_tarjetasDataTable();
                ta.Fill(tabla, IdAperturaAux, IdCajaAux, IdUsuarioAux);
                reportViewer1.LocalReport.DataSources.Clear();
                reportViewer1.LocalReport.EnableExternalImages = true;
                ParametrosReporte("DataSet1", (DataTable)tabla, "2020/Apertura/getVentasTarjetas.rdlc", reportViewer1);
                this.reportViewer1.RefreshReport();
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }
    }
}
