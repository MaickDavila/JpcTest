using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using Microsoft.Reporting.WinForms;

namespace Presentacion.Reportes._2020.AlmacenMovimiento.forms
{
    public partial class Form_sp_get_reporte_almacenMovimiento_by_id : Imprimir
    {

        public int IdAlmacenMovimiento { get; set; }


        public Form_sp_get_reporte_almacenMovimiento_by_id()
        {
            InitializeComponent();
        }

        private void Form_sp_get_reporte_almacenMovimiento_by_id_Load(object sender, EventArgs e)
        {
            Imprimir();
        }

        void Imprimir()
        {
            try
            {
                LLenar_2();

                //
                AlmacenMovimiento.DataSet.DataSet_sp_get_reporte_almacenMovimiento_by_idTableAdapters.sp_get_reporte_almacenMovimiento_by_idTableAdapter ta = new DataSet.DataSet_sp_get_reporte_almacenMovimiento_by_idTableAdapters.sp_get_reporte_almacenMovimiento_by_idTableAdapter();
                ta.Connection = new System.Data.SqlClient.SqlConnection(DataSetConexion);

                AlmacenMovimiento.DataSet.DataSet_sp_get_reporte_almacenMovimiento_by_id.sp_get_reporte_almacenMovimiento_by_idDataTable tabla = new DataSet.DataSet_sp_get_reporte_almacenMovimiento_by_id.sp_get_reporte_almacenMovimiento_by_idDataTable();
                ta.Fill(tabla, IdAlmacenMovimiento);
                reportViewer1.LocalReport.DataSources.Clear();
                reportViewer1.LocalReport.EnableExternalImages = true;
                ParametrosReporte("DataSet1", tabla,
                    "2020//AlmacenMovimiento//get_reporte_almacenMovimiento_by_id.rdlc", reportViewer1);
                this.reportViewer1.RefreshReport();
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
            }
        }
    }
}
