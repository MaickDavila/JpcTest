using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Presentacion.Reportes._2020.Reportes.ReporteGeneralPagosFacturacion.form
{
    public partial class ReporteGeneralPagosFacturacionForm : Imprimir
    {
        DateTime _FechaInicio, _FechaFin;
        public int IdCliente { get; set; }
        public DateTime FechaInicio { get => _FechaInicio; set => _FechaInicio = value; }
        public DateTime FechaFin { get => _FechaFin; set => _FechaFin = value; }
        public int IdUsuarioVendedor { get; set; }
        public bool OnlyDedudas { get; set; }

        public ReporteGeneralPagosFacturacionForm()
        {
            InitializeComponent();
        }

        private void ReporteGeneralPagosFacturacionForm_Load(object sender, EventArgs e)
        {
            Imprimir();
        }

        void Imprimir()
        {
            try
            {

                Dataset.ReporteGeneralPagosFacturacionDataSetTableAdapters.sp_reporte_general_pagos_facturacionTableAdapter ta = new Dataset.ReporteGeneralPagosFacturacionDataSetTableAdapters.sp_reporte_general_pagos_facturacionTableAdapter();
                ta.Connection = new System.Data.SqlClient.SqlConnection(DataSetConexion);

                Dataset.ReporteGeneralPagosFacturacionDataSet.sp_reporte_general_pagos_facturacionDataTable tabla = new Dataset.ReporteGeneralPagosFacturacionDataSet.sp_reporte_general_pagos_facturacionDataTable();
                ta.Fill(tabla, FechaInicio, FechaFin,IdCliente, IdUsuarioVendedor, OnlyDedudas);



                ParametrosReporte("DataSet1", (DataTable)tabla, "2020\\Reportes\\ReporteGeneralPagosFacturacion\\ReporteGeneralPagosFacturacion.rdlc", reportViewer1);

            }
            catch (Exception e)
            {

                MessageBox.Show(e.Message);
            }
        }
    }
}
