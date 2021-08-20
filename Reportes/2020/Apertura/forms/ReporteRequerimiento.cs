using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using Presentacion.Reportes._2020.Apertura.Dataset;
using Presentacion.Reportes._2020.Apertura.Dataset.SpGetReporteRequerimientoTableAdapters;

namespace Presentacion.Reportes._2020.Apertura.forms
{
    public partial class ReporteRequerimiento : Imprimir
    {
        public int NumeroAperturaAux { get; set; }
        public int IdCajaAux { get; set; }
        public int IdUsuarioAux { get; set; }

        public ReporteRequerimiento()
        {
            InitializeComponent();
        }

        private void ReporteRequerimiento_Load(object sender, EventArgs e)
        {
            Imprimir();
        }

        void Imprimir()
        {
            try
            {
                LLenar_2();

                var ta = new SpGetReporteRequerimientoTableAdapter
                {
                    Connection = new System.Data.SqlClient.SqlConnection(DataSetConexion)
                };

                var tabla =
                    new SpGetReporteRequerimiento.SpGetReporteRequerimientoDataTable();
                ta.Fill(tabla, NumeroAperturaAux, IdCajaAux, IdUsuarioAux);
                reportViewer1.LocalReport.DataSources.Clear();
                reportViewer1.LocalReport.EnableExternalImages = true;
                ParametrosReporte("DataSet1", (DataTable)tabla, "2020/Apertura/ReporteRequerimiento.rdlc", reportViewer1);
                this.reportViewer1.RefreshReport();
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }
    }
}
