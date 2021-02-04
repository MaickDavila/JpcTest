using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Presentacion.Reportes._2020.AlmacenMovimiento.forms
{
    public partial class Form_sp_get_reporte_cobranza_vendedor_almacenMovimiento : Imprimir
    {
        public DateTime FechaInicio { get; set; }
        public DateTime FechaFin { get; set; }
        public int IdVendedor { get; set; }

        public Form_sp_get_reporte_cobranza_vendedor_almacenMovimiento()
        {
            InitializeComponent();
        }

        private void Form_sp_get_reporte_cobranza_vendedor_almacenMovimiento_Load(object sender, EventArgs e)
        {
            Imprimir();
        }

        void Imprimir()
        {
            try
            {
                LLenar_2();

                AlmacenMovimiento.DataSet.DataSet_sp_get_reporte_cobranza_vendedor_almacenMovimientoTableAdapters.sp_get_reporte_cobranza_vendedor_almacenMovimientoTableAdapter ta = new DataSet.DataSet_sp_get_reporte_cobranza_vendedor_almacenMovimientoTableAdapters.sp_get_reporte_cobranza_vendedor_almacenMovimientoTableAdapter();
                ta.Connection = new System.Data.SqlClient.SqlConnection(DataSetConexion);

                AlmacenMovimiento.DataSet.DataSet_sp_get_reporte_cobranza_vendedor_almacenMovimiento.sp_get_reporte_cobranza_vendedor_almacenMovimientoDataTable tabla = new DataSet.DataSet_sp_get_reporte_cobranza_vendedor_almacenMovimiento.sp_get_reporte_cobranza_vendedor_almacenMovimientoDataTable();
                ta.Fill(tabla, FechaInicio, FechaFin, IdVendedor);
                reportViewer1.LocalReport.DataSources.Clear();
                reportViewer1.LocalReport.EnableExternalImages = true;
                ParametrosReporte("DataSet1", (DataTable)tabla, "2020//AlmacenMovimiento//get_reporte_cobranza_vendedor_almacenMovimiento.rdlc", reportViewer1);
                this.reportViewer1.RefreshReport();
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
            }
        }
    }
}
