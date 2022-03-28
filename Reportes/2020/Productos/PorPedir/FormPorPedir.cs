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
using Presentacion.Reportes._2020.Productos.PorPedir.DataSetPorPedirTableAdapters;

namespace Presentacion.Reportes._2020.Productos.PorPedir
{
    public partial class FormPorPedir : Imprimir
    {
        public int IdAlmacen { get; set; }
        public bool Exportar { get; set; }

        public FormPorPedir()
        {
            InitializeComponent();
        }

        private void FormPorPedir_Load(object sender, EventArgs e)
        {
            ImprimirReporte();
        }

        void ImprimirReporte()
        {
            try
            {

                var ta = new SpReporteProductosPorPedirTableAdapter() { Connection = new SqlConnection(DataSetConexion) };
                var tabla = new DataSetPorPedir().SpReporteProductosPorPedir;
                ta.Fill(tabla, IdAlmacen);
                ParametrosReporte("DataSet1", tabla, "2020\\Productos\\PorPedir\\ReportPorPedir.rdlc", reportViewer1);
                this.reportViewer1.RefreshReport();
                ExportarData(tabla);
            }
            catch (Exception e)
            {
                var message = e.InnerException != null ? e.InnerException.ToString() : e.Message;
                MessageBox.Show($@"Ocurrio un error al generar el reporte! {message}");
            }
        }

        void ExportarData(DataTable table)
        {
            if(!Exportar) return;
            try
            {
                var list = (from DataRow row in table.Rows
                    let cantidad = row["ProductosAPedir"].ToString()
                    where cantidad.ToDouble() > 0
                    let codigobarra = row["codigobarra"].ToString()
                    let precio = row["preciounitario"].ToString()
                    let nombre = row["nombreProducto"].ToString()
                    select $"{codigobarra}-{cantidad}-{precio}-{nombre}").ToList();
                var detalles_str = string.Join(",", list);
                var filename = $"exp-ppp-{DateTime.Now}.txt";
                filename = filename.Replace("/", "-");
                filename = filename.Replace(":", "-");
                var save = new SaveFileDialog();
                save.Filter = "txt files (*.txt)|*.txt|All files (*.*)|*.*";
                save.FileName = filename;
                if (save.ShowDialog() != DialogResult.OK) return;
                var path = save.FileName;
                Utils.ExportToTxt(detalles_str, true, path);
            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error al exportar", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }
    }
}
