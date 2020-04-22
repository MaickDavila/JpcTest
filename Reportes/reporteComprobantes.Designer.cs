namespace Presentacion.Reportes
{
    partial class reporteComprobantes
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            Microsoft.Reporting.WinForms.ReportDataSource reportDataSource1 = new Microsoft.Reporting.WinForms.ReportDataSource();
            this.spReporteComprobanteBindingSource = new System.Windows.Forms.BindingSource(this.components);
            this.sistemaDataSet = new SistemaDataSet();
            this.reportViewer1 = new Microsoft.Reporting.WinForms.ReportViewer();
            this.spReporteComprobanteTableAdapter = new SistemaDataSetTableAdapters.spReporteComprobanteTableAdapter();
            this.tablaaux = new System.Windows.Forms.DataGridView();
            ((System.ComponentModel.ISupportInitialize)(this.spReporteComprobanteBindingSource)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.sistemaDataSet)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.tablaaux)).BeginInit();
            this.SuspendLayout();
            // 
            // spReporteComprobanteBindingSource
            // 
            this.spReporteComprobanteBindingSource.DataMember = "spReporteComprobante";
            this.spReporteComprobanteBindingSource.DataSource = this.sistemaDataSet;
            // 
            // sistemaDataSet
            // 
            this.sistemaDataSet.DataSetName = "SistemaDataSet";
            this.sistemaDataSet.SchemaSerializationMode = System.Data.SchemaSerializationMode.IncludeSchema;
            // 
            // reportViewer1
            // 
            this.reportViewer1.Dock = System.Windows.Forms.DockStyle.Fill;
            reportDataSource1.Name = "DataSet1";
            reportDataSource1.Value = this.spReporteComprobanteBindingSource;
            this.reportViewer1.LocalReport.DataSources.Add(reportDataSource1);
            this.reportViewer1.LocalReport.ReportEmbeddedResource = "Presentacion.Reportes.Report1.rdlc";
            this.reportViewer1.Location = new System.Drawing.Point(0, 0);
            this.reportViewer1.Name = "reportViewer1";
            this.reportViewer1.ServerReport.BearerToken = null;
            this.reportViewer1.Size = new System.Drawing.Size(800, 450);
            this.reportViewer1.TabIndex = 0;
            this.reportViewer1.Load += new System.EventHandler(this.reportViewer1_Load);
            // 
            // spReporteComprobanteTableAdapter
            // 
            this.spReporteComprobanteTableAdapter.ClearBeforeFill = true;
            // 
            // tablaaux
            // 
            this.tablaaux.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.tablaaux.Location = new System.Drawing.Point(12, 31);
            this.tablaaux.Name = "tablaaux";
            this.tablaaux.Size = new System.Drawing.Size(15, 21);
            this.tablaaux.TabIndex = 1;
            this.tablaaux.Visible = false;
            // 
            // reporteComprobantes
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(800, 450);
            this.Controls.Add(this.reportViewer1);
            this.Controls.Add(this.tablaaux);
            this.Name = "reporteComprobantes";
            this.Text = "reporteComprobantes";
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.reporteComprobantes_FormClosing);
            this.Load += new System.EventHandler(this.reporteComprobantes_Load);
            ((System.ComponentModel.ISupportInitialize)(this.spReporteComprobanteBindingSource)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.sistemaDataSet)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.tablaaux)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion
        private System.Windows.Forms.BindingSource spReporteComprobanteBindingSource;
        private SistemaDataSet sistemaDataSet;
        private SistemaDataSetTableAdapters.spReporteComprobanteTableAdapter spReporteComprobanteTableAdapter;
        public Microsoft.Reporting.WinForms.ReportViewer reportViewer1;
        private System.Windows.Forms.DataGridView tablaaux;
    }
}