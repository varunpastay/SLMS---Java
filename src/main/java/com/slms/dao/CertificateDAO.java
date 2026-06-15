package com.slms.dao;

import com.slms.dto.CertificateDTO;
import java.sql.SQLException;
import java.util.List;

public interface CertificateDAO {
    void save(CertificateDTO certificate) throws SQLException;
    CertificateDTO findById(int id) throws SQLException;
    CertificateDTO findByCode(String code) throws SQLException;
    CertificateDTO findByStudentAndCourse(int studentId, int courseId) throws SQLException;
    List<CertificateDTO> findByStudent(int studentId) throws SQLException;
    boolean exists(int studentId, int courseId) throws SQLException;
}
