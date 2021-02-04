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
    public partial class Form_sp_get_reporte_cobranza_almacenMovimiento : Imprimir  
    {
        public DateTime Fecha { get; set; }
        public Form_sp_get_reporte_cobranza_almacenMovimiento()
        {
            InitializeComponent();
        }

        private void Form_sp_get_reporte_cobranza_almacenMovimiento_Load(object sender, EventArgs e)
        {
            Imprimir();
        }

        void Imprimir()
        {
            try
            {
                LLenar_2();

                //
                AlmacenMovimiento.DataSet.DataSet_sp_get_reporte_cobranza_almacenMovimientoTableAdapters.sp_get_reporte_cobranza_almacenMovimientoTableAdapter ta = new DataSet.DataSet_sp_get_reporte_cobranza_almacenMovimientoTableAdapters.sp_get_reporte_cobranza_almacenMovimientoTableAdapter();
                ta.Connection = new System.Data.SqlClient.SqlConnection(DataSetConexion);

                AlmacenMovimiento.DataSet.DataSet_sp_get_reporte_cobranza_almacenMovimiento.sp_get_reporte_cobranza_almacenMovimientoDataTable tabla = new DataSet.DataSet_sp_get_reporte_cobranza_almacenMovimiento.sp_get_reporte_cobranza_almacenMovimientoDataTable();
                ta.Fill(tabla, Fecha);
                reportViewer1.LocalReport.DataSources.Clear();
                reportViewer1.LocalReport.EnableExternalImages = true;
                ParametrosReporte("DataSet1", (DataTable)tabla, "2020//AlmacenMovimiento//get_reporte_cobranza_almacenMovimiento.rdlc", reportViewer1);
                //
                //
                AlmacenMovimiento.DataSet.DataSet_sp_get_reporte_movimiento_emitidos_almacenMovimientoTableAdapters.sp_get_reporte_movimiento_emitidos_almacenMovimientoTableAdapter ta2 = new DataSet.DataSet_sp_get_reporte_movimiento_emitidos_almacenMovimientoTableAdapters.sp_get_reporte_movimiento_emitidos_almacenMovimientoTableAdapter();
                ta2.Connection = new System.Data.SqlClient.SqlConnection(DataSetConexion);

                AlmacenMovimiento.DataSet.DataSet_sp_get_reporte_movimiento_emitidos_almacenMovimiento.sp_get_reporte_movimiento_emitidos_almacenMovimientoDataTable tabla2 = new DataSet.DataSet_sp_get_reporte_movimiento_emitidos_almacenMovimiento.sp_get_reporte_movimiento_emitidos_almacenMovimientoDataTable();
                ta2.Fill(tabla2, Fecha);
                ParametrosReporte("DataSet2", (DataTable)tabla2, "2020//AlmacenMovimiento//get_reporte_cobranza_almacenMovimiento.rdlc", reportViewer1);
                this.reportViewer1.RefreshReport();
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
            }
        }
    }
}
