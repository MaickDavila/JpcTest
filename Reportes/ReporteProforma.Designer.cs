﻿namespace Presentacion.Reportes
{
    partial class ReporteProforma
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
            this.reportViewer1 = new Microsoft.Reporting.WinForms.ReportViewer();
            this.spFormatoproformaTableAdapter1 = new DataSetProformaTableAdapters.spFormatoproformaTableAdapter();
            this.SuspendLayout();
            // 
            // reportViewer1
            // 
            this.reportViewer1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.reportViewer1.LocalReport.ReportEmbeddedResource = "Presentacion.Reportes.Proforma.rdlc";
            this.reportViewer1.Location = new System.Drawing.Point(0, 0);
            this.reportViewer1.Name = "reportViewer1";
            this.reportViewer1.ServerReport.BearerToken = null;
            this.reportViewer1.Size = new System.Drawing.Size(471, 375);
            this.reportViewer1.TabIndex = 0;
            // 
            // spFormatoproformaTableAdapter1
            // 
            this.spFormatoproformaTableAdapter1.ClearBeforeFill = true;
            // 
            // ReporteProforma
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(471, 375);
            this.Controls.Add(this.reportViewer1);
            this.Name = "ReporteProforma";
            this.Text = "ReporteProforma";
            this.Load += new System.EventHandler(this.ReporteProforma_Load);
            this.ResumeLayout(false);

        }

        #endregion

        private Microsoft.Reporting.WinForms.ReportViewer reportViewer1;
        private DataSetProformaTableAdapters.spFormatoproformaTableAdapter spFormatoproformaTableAdapter1;
    }
}